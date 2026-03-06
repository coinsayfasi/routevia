-- Automated curated pipeline: raw ingestion -> normalization -> moderation -> publish

create table if not exists public.source_runs (
  id uuid primary key default gen_random_uuid(),
  source text not null check (source in ('google','osm','wikimedia')),
  scope text not null check (scope in ('district','province')),
  province_id uuid references public.provinces(id) on delete set null,
  district_id uuid references public.districts(id) on delete set null,
  started_at timestamptz not null default now(),
  finished_at timestamptz,
  status text not null check (status in ('running','done','failed')),
  stats jsonb not null default '{}'::jsonb,
  last_error text
);

create index if not exists source_runs_source_started_idx
  on public.source_runs(source, started_at desc);
create index if not exists source_runs_status_idx
  on public.source_runs(status, started_at desc);

create table if not exists public.raw_places (
  id uuid primary key default gen_random_uuid(),
  source text not null check (source in ('google','osm','wikimedia')),
  source_place_id text not null,
  name text not null,
  lat double precision not null,
  lng double precision not null,
  province_id uuid not null references public.provinces(id) on delete cascade,
  district_id uuid not null references public.districts(id) on delete cascade,
  types text[],
  rating numeric,
  user_ratings_total int,
  price_level int,
  website text,
  phone text,
  address text,
  raw_hash text not null,
  fetched_at timestamptz not null default now(),
  normalized_at timestamptz,
  unique(source, source_place_id)
);

create index if not exists raw_places_district_quality_idx
  on public.raw_places(district_id, rating desc nulls last, user_ratings_total desc nulls last);
create index if not exists raw_places_source_fetched_idx
  on public.raw_places(source, fetched_at desc);

create table if not exists public.curated_candidates (
  id uuid primary key default gen_random_uuid(),
  raw_place_id uuid not null references public.raw_places(id) on delete cascade,
  province_id uuid not null references public.provinces(id) on delete cascade,
  district_id uuid not null references public.districts(id) on delete cascade,
  name text not null,
  category text not null check (category in ('nature','historical','viewpoint','beach','activity','food','cafe','lodging','museum','tour')),
  tags text[] not null default '{}'::text[],
  short_desc text not null check (char_length(short_desc) <= 160),
  history_tip text not null check (char_length(history_tip) <= 160),
  eat_tip text not null check (char_length(eat_tip) <= 160),
  pro_tip text not null check (char_length(pro_tip) <= 160),
  score_boost numeric not null default 0,
  status text not null default 'draft' check (status in ('draft','approved','rejected')),
  raw_hash text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(raw_place_id, raw_hash)
);

create index if not exists curated_candidates_status_district_idx
  on public.curated_candidates(status, district_id);
create index if not exists curated_candidates_district_status_idx
  on public.curated_candidates(district_id, status);

create table if not exists public.place_sources (
  place_id uuid not null references public.places(id) on delete cascade,
  source text not null check (source in ('google','osm','wikimedia','curated')),
  source_place_id text not null,
  confidence numeric not null default 0.7,
  created_at timestamptz not null default now(),
  primary key (place_id, source, source_place_id)
);

create index if not exists place_sources_source_place_idx
  on public.place_sources(source, source_place_id);

alter table public.source_runs enable row level security;
alter table public.raw_places enable row level security;
alter table public.curated_candidates enable row level security;
alter table public.place_sources enable row level security;

-- Service-role-only in practice: no anon/auth policy grants.
drop policy if exists source_runs_no_access on public.source_runs;
create policy source_runs_no_access on public.source_runs
  for all to anon, authenticated
  using (false)
  with check (false);

drop policy if exists raw_places_no_access on public.raw_places;
create policy raw_places_no_access on public.raw_places
  for all to anon, authenticated
  using (false)
  with check (false);

-- Curated candidates: authenticated read, admin write.
drop policy if exists curated_candidates_read_authenticated on public.curated_candidates;
create policy curated_candidates_read_authenticated on public.curated_candidates
  for select to authenticated
  using (true);

drop policy if exists curated_candidates_admin_insert on public.curated_candidates;
create policy curated_candidates_admin_insert on public.curated_candidates
  for insert to authenticated
  with check (public.is_admin(auth.uid()));

drop policy if exists curated_candidates_admin_update on public.curated_candidates;
create policy curated_candidates_admin_update on public.curated_candidates
  for update to authenticated
  using (public.is_admin(auth.uid()))
  with check (public.is_admin(auth.uid()));

drop policy if exists curated_candidates_admin_delete on public.curated_candidates;
create policy curated_candidates_admin_delete on public.curated_candidates
  for delete to authenticated
  using (public.is_admin(auth.uid()));

-- place_sources admin readable only
drop policy if exists place_sources_admin_select on public.place_sources;
create policy place_sources_admin_select on public.place_sources
  for select to authenticated
  using (public.is_admin(auth.uid()));

drop policy if exists place_sources_admin_write on public.place_sources;
create policy place_sources_admin_write on public.place_sources
  for all to authenticated
  using (public.is_admin(auth.uid()))
  with check (public.is_admin(auth.uid()));

create or replace function public.approve_curated_candidates(
  p_candidate_ids uuid[],
  p_action text default 'approve'
)
returns table(candidate_id uuid, status text, place_id uuid)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_action text := lower(coalesce(p_action, 'approve'));
  v_rec record;
  v_slug citext;
  v_place_id uuid;
begin
  if coalesce(current_setting('request.jwt.claim.role', true), '') <> 'service_role'
     and (auth.uid() is null or not public.is_admin(auth.uid())) then
    raise exception 'admin_required';
  end if;

  if v_action not in ('approve','reject') then
    raise exception 'invalid_action';
  end if;

  if p_candidate_ids is null or coalesce(array_length(p_candidate_ids, 1), 0) = 0 then
    return;
  end if;

  if v_action = 'reject' then
    update public.curated_candidates c
      set status = 'rejected', updated_at = now()
    where c.id = any(p_candidate_ids);

    return query
    select c.id, c.status, null::uuid
    from public.curated_candidates c
    where c.id = any(p_candidate_ids);
    return;
  end if;

  for v_rec in
    select c.id as candidate_id,
           c.raw_place_id,
           c.province_id,
           c.district_id,
           c.name,
           c.category,
           c.tags,
           c.short_desc,
           c.history_tip,
           c.eat_tip,
           c.pro_tip,
           c.score_boost,
           rp.source,
           rp.source_place_id,
           rp.user_ratings_total,
           rp.price_level,
           rp.lat,
           rp.lng,
           rp.website,
           rp.phone
    from public.curated_candidates c
    join public.raw_places rp on rp.id = c.raw_place_id
    where c.id = any(p_candidate_ids)
      and c.status = 'draft'
  loop
    v_slug := left(regexp_replace(lower(v_rec.name || '-' || v_rec.district_id::text), '[^a-z0-9]+', '-', 'g'), 120)::citext;

    insert into public.places (
      province_id, district_id, name, slug, category, geog, short_summary,
      best_time, duration_min, tags, popularity_score, is_free, price_level,
      website, phone, source_kind, source_url, is_published
    ) values (
      v_rec.province_id,
      v_rec.district_id,
      v_rec.name,
      v_slug,
      v_rec.category::public.place_category,
      st_setsrid(st_makepoint(v_rec.lng, v_rec.lat), 4326)::geography,
      v_rec.short_desc,
      case when v_rec.tags && array['sunset']::text[] then 'sunset'::public.best_time else 'day'::public.best_time end,
      case when v_rec.category in ('food','cafe') then 90 else 120 end,
      v_rec.tags,
      greatest(coalesce(v_rec.user_ratings_total, 0), 40),
      false,
      v_rec.price_level,
      v_rec.website,
      v_rec.phone,
      'curated'::public.source_kind,
      null,
      true
    )
    on conflict (province_id, slug) do update set
      province_id = excluded.province_id,
      district_id = excluded.district_id,
      name = excluded.name,
      category = excluded.category,
      geog = excluded.geog,
      short_summary = excluded.short_summary,
      tags = excluded.tags,
      popularity_score = greatest(public.places.popularity_score, excluded.popularity_score),
      price_level = excluded.price_level,
      website = coalesce(excluded.website, public.places.website),
      phone = coalesce(excluded.phone, public.places.phone),
      source_kind = 'curated'::public.source_kind,
      is_published = true,
      updated_at = now()
    returning id into v_place_id;

    insert into public.place_details(place_id, history_bullets, eat_drink_bullets, tips_bullets)
    values (
      v_place_id,
      array[left(v_rec.history_tip, 160)],
      array[left(v_rec.eat_tip, 160)],
      array[left(v_rec.pro_tip, 160)]
    )
    on conflict (place_id) do update
      set history_bullets = excluded.history_bullets,
          eat_drink_bullets = excluded.eat_drink_bullets,
          tips_bullets = excluded.tips_bullets;

    insert into public.place_sources(place_id, source, source_place_id, confidence)
    values (v_place_id, v_rec.source, v_rec.source_place_id, 0.9)
    on conflict (place_id, source, source_place_id) do update
      set confidence = greatest(public.place_sources.confidence, excluded.confidence);

    update public.places
      set score = coalesce(score, 0) + coalesce(v_rec.score_boost, 0) + 10
    where id = v_place_id;

    update public.curated_candidates
      set status = 'approved', updated_at = now()
    where id = v_rec.candidate_id;
  end loop;

  return query
  select c.id, c.status, pl.id as place_id
  from public.curated_candidates c
  left join public.places pl on pl.province_id = c.province_id and pl.district_id = c.district_id and pl.name = c.name
  where c.id = any(p_candidate_ids);
end;
$$;

revoke all on function public.approve_curated_candidates(uuid[], text) from public;
grant execute on function public.approve_curated_candidates(uuid[], text) to authenticated;

create or replace function public.export_curated_rows()
returns table (
  name text,
  province text,
  district text,
  category text,
  lat double precision,
  lng double precision,
  price_level int,
  duration_min int,
  tags text,
  short_desc text,
  history_tip text,
  eat_tip text,
  pro_tip text
)
language sql
security definer
set search_path = public
as $$
  select
    p.name,
    pr.name as province,
    coalesce(d.name, pr.name) as district,
    p.category::text as category,
    st_y(p.geog::geometry) as lat,
    st_x(p.geog::geometry) as lng,
    p.price_level,
    p.duration_min,
    array_to_string(coalesce(p.tags, '{}'::text[]), ',') as tags,
    p.short_summary as short_desc,
    coalesce(pd.history_bullets[1], '') as history_tip,
    coalesce(pd.eat_drink_bullets[1], '') as eat_tip,
    coalesce(pd.tips_bullets[1], '') as pro_tip
  from public.places p
  join public.provinces pr on pr.id = p.province_id
  left join public.districts d on d.id = p.district_id
  left join public.place_details pd on pd.place_id = p.id
  where p.source_kind = 'curated'::public.source_kind
    and coalesce(p.is_published, true) = true
  order by pr.name, coalesce(d.name, pr.name), p.score desc, p.name;
$$;

revoke all on function public.export_curated_rows() from public;
grant execute on function public.export_curated_rows() to authenticated;

-- Daily low-density prioritization (best-effort pg_cron).
create or replace function public.prioritize_low_density_districts(p_limit int default 50)
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  v_updated int := 0;
begin
  with low as (
    select d.id as district_id, count(p.id)::int as place_count
    from public.districts d
    left join public.places p on p.district_id = d.id and coalesce(p.is_published, true) = true
    group by d.id
    order by count(p.id) asc
    limit greatest(1, p_limit)
  )
  update public.district_ingest_jobs j
    set status = case when j.status = 'done' then 'queued' else j.status end,
        next_run_at = now(),
        priority_score = greatest(coalesce(j.priority_score, 0), 4500 + (50 - least(low.place_count, 50)) * 8),
        updated_at = now()
  from low
  where j.district_id = low.district_id
    and j.status in ('queued','failed','done');

  get diagnostics v_updated = row_count;
  return v_updated;
end;
$$;

-- Schedule only if pg_cron is available in the environment.
do $$
begin
  perform 1 from pg_extension where extname = 'pg_cron';
  if found then
    begin
      perform cron.unschedule('routevia-prioritize-low-density');
    exception when others then
      null;
    end;
    perform cron.schedule(
      'routevia-prioritize-low-density',
      '15 3 * * *',
      $job$select public.prioritize_low_density_districts(50);$job$
    );
  end if;
exception when others then
  null;
end $$;
