-- Onboarding + growth loops + user signals + top picks cache

-- Profiles personalization fields
alter table if exists public.profiles
  add column if not exists onboarding_completed boolean not null default false,
  add column if not exists pref_tags text[] not null default '{}'::text[],
  add column if not exists pref_pace text,
  add column if not exists allow_location boolean,
  add column if not exists allow_notifications boolean,
  add column if not exists referral_code text;

create unique index if not exists profiles_referral_code_uidx
  on public.profiles(referral_code)
  where referral_code is not null;

-- Places engagement + tier fields
alter table if exists public.places
  add column if not exists quality_tier text not null default 'normal',
  add column if not exists curated_rank int not null default 0,
  add column if not exists visit_count int not null default 0,
  add column if not exists favorite_count int not null default 0,
  add column if not exists avg_user_rating numeric not null default 0;

alter table if exists public.places
  drop constraint if exists places_quality_tier_check;
alter table if exists public.places
  add constraint places_quality_tier_check check (quality_tier in ('top','normal','low'));

-- User signals
create table if not exists public.user_signals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  place_id uuid not null references public.places(id) on delete cascade,
  type text not null check (type in ('checkin','favorite','rating')),
  rating numeric,
  created_at timestamptz not null default now()
);

create index if not exists user_signals_place_type_idx
  on public.user_signals(place_id, type, created_at desc);
create index if not exists user_signals_user_created_idx
  on public.user_signals(user_id, created_at desc);

-- limit repeated favorite/checkin spam from same user/place/type
create unique index if not exists user_signals_user_place_once_uidx
  on public.user_signals(user_id, place_id, type)
  where type in ('checkin','favorite');

-- top picks cache
create table if not exists public.top_picks (
  district_id uuid not null references public.districts(id) on delete cascade,
  category_key text,
  place_id uuid not null references public.places(id) on delete cascade,
  rank int not null,
  score_snapshot numeric not null,
  created_at timestamptz not null default now(),
  primary key (district_id, category_key, rank)
);

create index if not exists top_picks_place_idx on public.top_picks(place_id);

-- Referrals
create table if not exists public.referrals (
  id uuid primary key default gen_random_uuid(),
  referrer_user_id uuid not null references auth.users(id) on delete cascade,
  referee_user_id uuid not null references auth.users(id) on delete cascade,
  code text not null,
  created_at timestamptz not null default now(),
  unique(referee_user_id)
);

create index if not exists referrals_code_idx on public.referrals(code);

-- Entitlements
create table if not exists public.user_entitlements (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  entitlement_key text not null,
  expires_at timestamptz not null,
  created_at timestamptz not null default now()
);

create index if not exists user_entitlements_user_idx
  on public.user_entitlements(user_id, expires_at desc);

-- Feedback
create table if not exists public.feedback (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  message text not null,
  rating numeric,
  created_at timestamptz not null default now()
);

create index if not exists feedback_created_idx on public.feedback(created_at desc);

-- Lightweight event log
create table if not exists public.app_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  event_name text not null,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists app_events_name_created_idx
  on public.app_events(event_name, created_at desc);

-- RLS
alter table public.user_signals enable row level security;
alter table public.top_picks enable row level security;
alter table public.referrals enable row level security;
alter table public.user_entitlements enable row level security;
alter table public.feedback enable row level security;
alter table public.app_events enable row level security;

-- user_signals: read public for published places, write own only
drop policy if exists user_signals_select_public on public.user_signals;
create policy user_signals_select_public
on public.user_signals
for select
to anon, authenticated
using (
  exists (
    select 1 from public.places p
    where p.id = user_signals.place_id and p.is_published = true
  )
);

drop policy if exists user_signals_insert_own on public.user_signals;
create policy user_signals_insert_own
on public.user_signals
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists user_signals_delete_own on public.user_signals;
create policy user_signals_delete_own
on public.user_signals
for delete
to authenticated
using (auth.uid() = user_id or public.is_admin(auth.uid()));

-- top_picks public read, admin write only
drop policy if exists top_picks_select_public on public.top_picks;
create policy top_picks_select_public
on public.top_picks
for select
to anon, authenticated
using (true);

drop policy if exists top_picks_admin_write on public.top_picks;
create policy top_picks_admin_write
on public.top_picks
for all
to authenticated
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

-- referrals / entitlements / feedback / events policies
drop policy if exists referrals_select_own_or_admin on public.referrals;
create policy referrals_select_own_or_admin
on public.referrals
for select
to authenticated
using (auth.uid() = referrer_user_id or auth.uid() = referee_user_id or public.is_admin(auth.uid()));

drop policy if exists referrals_admin_write on public.referrals;
create policy referrals_admin_write
on public.referrals
for all
to authenticated
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

drop policy if exists entitlements_select_own_or_admin on public.user_entitlements;
create policy entitlements_select_own_or_admin
on public.user_entitlements
for select
to authenticated
using (auth.uid() = user_id or public.is_admin(auth.uid()));

drop policy if exists entitlements_admin_write on public.user_entitlements;
create policy entitlements_admin_write
on public.user_entitlements
for all
to authenticated
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

drop policy if exists feedback_insert_auth on public.feedback;
create policy feedback_insert_auth
on public.feedback
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists feedback_select_own_or_admin on public.feedback;
create policy feedback_select_own_or_admin
on public.feedback
for select
to authenticated
using (auth.uid() = user_id or public.is_admin(auth.uid()));

drop policy if exists app_events_insert_auth on public.app_events;
create policy app_events_insert_auth
on public.app_events
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists app_events_select_own_or_admin on public.app_events;
create policy app_events_select_own_or_admin
on public.app_events
for select
to authenticated
using (auth.uid() = user_id or public.is_admin(auth.uid()));

-- Helpers
create or replace function public.generate_referral_code(p_user_id uuid)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_code text;
  v_exists int;
begin
  select referral_code into v_code from public.profiles where id = p_user_id;
  if v_code is not null and length(v_code) >= 6 then
    return v_code;
  end if;

  loop
    v_code := upper(substr(encode(gen_random_bytes(6), 'hex'), 1, 8));
    select count(*) into v_exists from public.profiles where referral_code = v_code;
    exit when v_exists = 0;
  end loop;

  update public.profiles
  set referral_code = v_code
  where id = p_user_id;

  return v_code;
end;
$$;

-- score helpers
create or replace function public.recalc_place_signal_stats(p_place_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_visit int;
  v_fav int;
  v_avg numeric;
begin
  select
    count(*) filter (where type = 'checkin')::int,
    count(*) filter (where type = 'favorite')::int,
    coalesce(avg(rating) filter (where type = 'rating'), 0)
  into v_visit, v_fav, v_avg
  from public.user_signals
  where place_id = p_place_id;

  update public.places
  set
    visit_count = coalesce(v_visit, 0),
    favorite_count = coalesce(v_fav, 0),
    avg_user_rating = coalesce(v_avg, 0)
  where id = p_place_id;

  perform public.refresh_place_score(p_place_id);
end;
$$;

create or replace function public.trg_user_signals_refresh_place()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  perform public.recalc_place_signal_stats(coalesce(new.place_id, old.place_id));
  return coalesce(new, old);
end;
$$;

drop trigger if exists trg_user_signals_refresh_place on public.user_signals;
create trigger trg_user_signals_refresh_place
after insert or update or delete on public.user_signals
for each row execute function public.trg_user_signals_refresh_place();

-- score formula override with growth signals
create or replace function public.compute_place_score_v2(p_place_id uuid)
returns numeric
language sql
stable
as $$
  with b as (
    select
      p.id,
      p.name,
      p.source_kind,
      coalesce(p.rating, p.google_rating, 0)::numeric as rating,
      coalesce(p.rating_count, p.google_review_count, 0)::numeric as rating_count,
      coalesce(p.popularity_score, 0)::numeric as popularity,
      coalesce(cd.default_priority, 1)::numeric as cat_priority,
      coalesce(p.curated_rank, 0)::numeric as curated_rank,
      coalesce(p.visit_count, 0)::numeric as visit_count,
      coalesce(p.favorite_count, 0)::numeric as favorite_count,
      coalesce(p.avg_user_rating, 0)::numeric as avg_user_rating,
      exists (select 1 from public.place_media pm where pm.place_id = p.id and (pm.is_primary = true or pm.sort_order = 0)) as has_primary_photo,
      (coalesce(nullif(trim(p.hap_history), ''), '') <> ''
        or exists (select 1 from public.place_details pd where pd.place_id = p.id and coalesce(array_length(pd.history_bullets, 1), 0) > 0)
      ) as has_hap_history,
      (coalesce(nullif(trim(p.hap_eat), ''), '') <> ''
        or exists (select 1 from public.place_details pd where pd.place_id = p.id and coalesce(array_length(pd.eat_drink_bullets, 1), 0) > 0)
      ) as has_hap_eat,
      (coalesce(nullif(trim(p.hap_tips), ''), '') <> ''
        or exists (select 1 from public.place_details pd where pd.place_id = p.id and coalesce(array_length(pd.tips_bullets, 1), 0) > 0)
      ) as has_hap_tips,
      lower(trim(coalesce(p.name, ''))) as lname,
      coalesce(p.category_key, '') as category_key,
      p.category::text as category_raw
    from public.places p
    left join public.category_dictionary cd on cd.category_key = p.category_key
    where p.id = p_place_id
  ), s as (
    select greatest(
      0,
      (b.rating * 2.4)
      + (ln(1 + b.rating_count) * 1.2)
      + (b.popularity * 0.06)
      + (case when b.source_kind::text = 'curated' then 2.0 else 0 end)
      + (b.curated_rank * 0.25)
      + (b.visit_count * 0.3)
      + (b.favorite_count * 0.5)
      + (b.avg_user_rating * 0.5)
      + (case when b.has_primary_photo then 2.2 else 0 end)
      + (case when b.has_hap_history then 0.8 else 0 end)
      + (case when b.has_hap_eat then 0.8 else 0 end)
      + (case when b.has_hap_tips then 0.8 else 0 end)
      + (b.cat_priority * 1.3)
      - (
        case
          when b.lname in ('park', 'çocuk parkı', 'semt pazarı', 'pazar', 'market', 'parkı')
               and b.category_key not in ('historical_site', 'archeological_site', 'viewpoint', 'waterfall', 'canyon', 'beach', 'national_park')
               and b.category_raw not in ('historical', 'viewpoint', 'waterfall', 'canyon', 'beach')
          then 6.5
          else 0
        end
      )
    ) as v
    from b
  )
  select v from s;
$$;

-- update quality tier from score
create or replace function public.sync_place_quality_tier()
returns trigger
language plpgsql
as $$
begin
  if new.score >= 18 then
    new.quality_tier := 'top';
  elsif new.score >= 8 then
    new.quality_tier := 'normal';
  else
    new.quality_tier := 'low';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_sync_place_quality_tier on public.places;
create trigger trg_sync_place_quality_tier
before insert or update of score on public.places
for each row execute function public.sync_place_quality_tier();

-- top picks refresh cache by district
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

  -- overall top10, curated first and diversity by lightweight geo bucket
  insert into public.top_picks(district_id, category_key, place_id, rank, score_snapshot)
  with base as (
    select
      p.id,
      coalesce(p.category_key, p.category::text) as category_key,
      p.score,
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
        order by case when source_kind = 'curated' then 0 else 1 end, score desc, id
      ) as bucket_rank
    from base
  ), ranked as (
    select *,
      row_number() over (
        order by case when source_kind = 'curated' then 0 else 1 end, score desc, id
      ) as rn
    from dedup
    where bucket_rank = 1
  )
  select p_district_id, null::text, id, rn, score
  from ranked
  where rn <= 10;

  -- top8 per category
  insert into public.top_picks(district_id, category_key, place_id, rank, score_snapshot)
  with ranked as (
    select
      p.id,
      coalesce(p.category_key, p.category::text) as category_key,
      p.score,
      row_number() over (
        partition by coalesce(p.category_key, p.category::text)
        order by case when p.source_kind = 'curated' then 0 else 1 end, p.score desc, p.id
      ) as rn
    from public.places p
    where p.district_id = p_district_id
      and p.is_published = true
  )
  select p_district_id, category_key, id, rn, score
  from ranked
  where rn <= 8;
end;
$$;

-- convenience: refresh all districts
create or replace function public.refresh_top_picks_all(p_limit int default 200)
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  v_count int := 0;
  r record;
begin
  for r in
    select d.id
    from public.districts d
    order by d.created_at asc
    limit greatest(1, least(5000, coalesce(p_limit, 200)))
  loop
    perform public.refresh_top_picks(r.id);
    v_count := v_count + 1;
  end loop;
  return v_count;
end;
$$;

-- Auto refresh top picks on place score or publish changes
create or replace function public.trg_refresh_top_picks_for_district()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if coalesce(new.district_id, old.district_id) is not null then
    perform public.refresh_top_picks(coalesce(new.district_id, old.district_id));
  end if;
  return coalesce(new, old);
end;
$$;

drop trigger if exists trg_refresh_top_picks_for_district on public.places;
create trigger trg_refresh_top_picks_for_district
after insert or update of score, is_published, district_id, source_kind on public.places
for each row execute function public.trg_refresh_top_picks_for_district();
