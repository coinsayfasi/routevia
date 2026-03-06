-- App-owned scoring model (Google-decoupled ranking), no data loss.
set lock_timeout = '10s';
set statement_timeout = '15min';

do $$
begin
  -- Release stale lockers on places before schema change.
  perform pg_terminate_backend(a.pid)
  from pg_stat_activity a
  join pg_locks l on l.pid = a.pid
  join pg_class c on c.oid = l.relation
  where a.pid <> pg_backend_pid()
    and a.datname = current_database()
    and c.relname = 'places'
    and a.backend_type = 'client backend';
exception when others then
  raise notice 'lock cleanup skipped: %', sqlerrm;
end $$;

-- 1) New columns
alter table if exists public.places
  add column if not exists app_score numeric not null default 0,
  add column if not exists app_rating numeric,
  add column if not exists source_weight numeric not null default 1,
  add column if not exists checkin_count int not null default 0,
  add column if not exists plan_count int not null default 0,
  add column if not exists view_count int not null default 0;

alter table if exists public.places
  alter column rating_count set default 0;

-- NOTE: heavy backfill is intentionally moved out of migration apply path.
-- We keep migration fast and run backfill safely via manual SQL after deploy.

create index if not exists idx_places_app_score on public.places(app_score desc);
create index if not exists idx_places_district_published_app_score on public.places(district_id, is_published, app_score desc);

-- 2) Extend user_signals types (passive + active)
alter table if exists public.user_signals
  drop constraint if exists user_signals_type_check;
alter table if exists public.user_signals
  add constraint user_signals_type_check
  check (type in ('view','checkin','favorite','plan','rating'));

-- keep anti-spam uniqueness for strong actions only
drop index if exists user_signals_user_place_once_uidx;
create unique index if not exists user_signals_user_place_once_uidx
  on public.user_signals(user_id, place_id, type)
  where type in ('checkin','favorite','plan');

-- 3) Recalculate aggregated signals + popularity
create or replace function public.recalc_place_signal_stats(p_place_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_checkin int;
  v_fav int;
  v_plan int;
  v_view int;
  v_avg numeric;
  v_pop numeric;
begin
  select
    count(*) filter (where type = 'checkin')::int,
    count(*) filter (where type = 'favorite')::int,
    count(*) filter (where type = 'plan')::int,
    count(*) filter (where type = 'view')::int,
    coalesce(avg(rating) filter (where type = 'rating'), 0)
  into v_checkin, v_fav, v_plan, v_view, v_avg
  from public.user_signals
  where place_id = p_place_id;

  v_pop := coalesce(v_checkin, 0)
        + coalesce(v_fav, 0)
        + coalesce(v_plan, 0)
        + (coalesce(v_view, 0) * 0.3);

  update public.places
  set
    checkin_count = coalesce(v_checkin, 0),
    favorite_count = coalesce(v_fav, 0),
    plan_count = coalesce(v_plan, 0),
    view_count = coalesce(v_view, 0),
    avg_user_rating = coalesce(v_avg, 0),
    popularity_score = greatest(0, round(v_pop)::int)
  where id = p_place_id
    and (
      (not is_published)
      or (
        exists (select 1 from public.place_media pm where pm.place_id = places.id)
        and exists (select 1 from public.place_details pd where pd.place_id = places.id)
      )
    );

  perform public.refresh_place_app_score(p_place_id);
end;
$$;

-- 4) App score function
create or replace function public.compute_place_app_score(p_place_id uuid)
returns numeric
language sql
stable
as $$
  with b as (
    select
      p.id,
      coalesce(p.app_rating, p.rating, p.google_rating, 0)::numeric as app_rating,
      coalesce(p.rating_count, p.google_review_count, 0)::numeric as rating_count,
      coalesce(p.source_weight, case p.source_kind::text when 'curated' then 1.5 when 'google' then 1.0 when 'osm' then 0.8 else 1.0 end)::numeric as source_weight,
      coalesce(p.checkin_count, 0)::numeric as checkin_count,
      coalesce(p.favorite_count, 0)::numeric as favorite_count,
      coalesce(p.plan_count, 0)::numeric as plan_count,
      coalesce(p.view_count, 0)::numeric as view_count,
      coalesce(cd.default_priority, 1)::numeric as cat_priority,
      p.name,
      p.category_key,
      p.category::text as category_raw,
      p.geog,
      p.district_id
    from public.places p
    left join public.category_dictionary cd on cd.category_key = p.category_key
    where p.id = p_place_id
  ),
  s as (
    select
      b.*,
      (
        coalesce(b.checkin_count,0)
        + coalesce(b.favorite_count,0)
        + coalesce(b.plan_count,0)
        + (coalesce(b.view_count,0) * 0.3)
      )::numeric as popularity_signal,
      (
        case when exists (
          select 1 from public.place_media pm
          where pm.place_id = b.id
        ) then 1 else 0 end
      )::numeric as media_score,
      (
        case
          when b.district_id is not null and exists (
            select 1 from public.districts d
            where d.id = b.district_id
              and d.center_geog is not null
              and b.geog is not null
              and st_distance(b.geog, d.center_geog) <= 15000
          ) then 1
          when b.district_id is not null and exists (
            select 1 from public.districts d
            where d.id = b.district_id
              and d.center_geog is not null
              and b.geog is not null
              and st_distance(b.geog, d.center_geog) <= 30000
          ) then 0.6
          else 0.2
        end
      )::numeric as distance_bias
    from b
  )
  select greatest(
    0,
    (0.20 * s.app_rating)
    + (0.10 * ln(s.rating_count + 1))
    + (0.20 * s.source_weight)
    + (0.25 * s.popularity_signal)
    + (0.10 * s.media_score)
    + (0.10 * least(3, greatest(0, s.cat_priority / 4)))
    + (0.05 * s.distance_bias)
    - (
      case
        when lower(trim(coalesce(s.name, ''))) ~* '(core\\s*spot|çekirdek|dummy|test)'
        then 10
        else 0
      end
    )
  )
  from s;
$$;

create or replace function public.refresh_place_app_score(p_place_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_score numeric;
  v_can_update boolean;
begin
  select
    (not p.is_published) or (
      exists (select 1 from public.place_media pm where pm.place_id = p.id)
      and exists (select 1 from public.place_details pd where pd.place_id = p.id)
    )
  into v_can_update
  from public.places p
  where p.id = p_place_id;

  if not coalesce(v_can_update, false) then
    return;
  end if;

  select public.compute_place_app_score(p_place_id) into v_score;

  update public.places p
  set
    app_score = coalesce(v_score, 0),
    score = coalesce(v_score, 0) -- backward compatibility for existing queries
  where p.id = p_place_id;
end;
$$;

create or replace function public.trg_places_refresh_app_score()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  perform public.refresh_place_app_score(coalesce(new.id, old.id));
  return coalesce(new, old);
end;
$$;

drop trigger if exists trg_places_refresh_app_score on public.places;
create trigger trg_places_refresh_app_score
after insert or update of app_rating, rating, rating_count, google_rating, google_review_count, source_kind, source_weight, checkin_count, favorite_count, plan_count, view_count, popularity_score, category_key
on public.places
for each row execute function public.trg_places_refresh_app_score();

create or replace function public.trg_place_media_refresh_app_score()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  perform public.refresh_place_app_score(coalesce(new.place_id, old.place_id));
  return coalesce(new, old);
end;
$$;

drop trigger if exists trg_place_media_refresh_app_score_iud on public.place_media;
create trigger trg_place_media_refresh_app_score_iud
after insert or update or delete on public.place_media
for each row execute function public.trg_place_media_refresh_app_score();

-- 5) Top picks now use app_score
create or replace function public.refresh_top_picks(p_district_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_cluster_m int := 350;
begin
  delete from public.top_picks where district_id = p_district_id;

  insert into public.top_picks(district_id, category_key, place_id, rank, score_snapshot)
  with base as (
    select
      p.id,
      coalesce(p.category_key, p.category::text) as category_key,
      coalesce(p.app_score, p.score, 0) as app_score,
      p.source_kind,
      st_x(p.geog::geometry) as lng,
      st_y(p.geog::geometry) as lat,
      floor((st_x(p.geog::geometry) * 1000)::numeric / (v_cluster_m::numeric / 1000.0))::bigint as gx,
      floor((st_y(p.geog::geometry) * 1000)::numeric / (v_cluster_m::numeric / 1000.0))::bigint as gy
    from public.places p
    where p.district_id = p_district_id
      and p.is_published = true
  ), dedup as (
    select *,
      row_number() over (
        partition by gx, gy
        order by case when source_kind = 'curated' then 0 else 1 end, app_score desc, id
      ) as bucket_rank
    from base
  ), ranked as (
    select *,
      row_number() over (
        order by case when source_kind = 'curated' then 0 else 1 end, app_score desc, id
      ) as rn
    from dedup
    where bucket_rank = 1
  )
  select p_district_id, 'overall'::text, id, rn, app_score
  from ranked
  where rn <= 10;

  insert into public.top_picks(district_id, category_key, place_id, rank, score_snapshot)
  with ranked as (
    select
      p.id,
      coalesce(p.category_key, p.category::text) as category_key,
      coalesce(p.app_score, p.score, 0) as app_score,
      row_number() over (
        partition by coalesce(p.category_key, p.category::text)
        order by case when p.source_kind = 'curated' then 0 else 1 end, coalesce(p.app_score, p.score, 0) desc, p.id
      ) as rn
    from public.places p
    where p.district_id = p_district_id
      and p.is_published = true
  )
  select p_district_id, category_key, id, rn, app_score
  from ranked
  where rn <= 8;
end;
$$;

-- 6) Hourly scheduled refresh (if pg_cron available)
create or replace function public.recalculate_scores_every_1h(p_limit int default 6000)
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  v_count int := 0;
begin
  with cand as (
    select p.id
    from public.places p
    where (
      (not p.is_published)
      or (
        exists (select 1 from public.place_media pm where pm.place_id = p.id)
        and exists (select 1 from public.place_details pd where pd.place_id = p.id)
      )
    )
    order by p.updated_at desc nulls last
    limit greatest(100, least(coalesce(p_limit, 6000), 25000))
  )
  update public.places p
  set
    app_score = coalesce(public.compute_place_app_score(p.id), 0),
    score = coalesce(public.compute_place_app_score(p.id), 0)
  from cand
  where p.id = cand.id;
  get diagnostics v_count = row_count;

  perform public.refresh_top_picks_all(500);
  return v_count;
end;
$$;

do $$
begin
  if exists (select 1 from pg_extension where extname = 'pg_cron') then
    perform cron.unschedule(jobid) from cron.job where jobname = 'recalculate_scores_every_1h';
    perform cron.schedule('recalculate_scores_every_1h', '0 * * * *', $cron$select public.recalculate_scores_every_1h(6000);$cron$);
  end if;
exception when others then
  raise notice 'pg_cron schedule skipped: %', sqlerrm;
end $$;

-- Bootstrap backfill intentionally omitted from migration.
