create extension if not exists pgcrypto;
create extension if not exists citext;
create extension if not exists postgis;

do $$
begin
  if not exists (
    select 1
    from pg_type
    where typnamespace = 'public'::regnamespace
      and typname = 'source_kind'
  ) then
    create type public.source_kind as enum ('curated', 'google', 'osm');
  end if;
end $$;

do $$
begin
  if exists (
    select 1
    from pg_type
    where typnamespace = 'public'::regnamespace
      and typname = 'place_category'
  ) then
    if not exists (
      select 1
      from pg_enum e
      join pg_type t on t.oid = e.enumtypid
      where t.typname = 'place_category' and e.enumlabel = 'tour'
    ) then
      alter type public.place_category add value 'tour';
    end if;

    if not exists (
      select 1
      from pg_enum e
      join pg_type t on t.oid = e.enumtypid
      where t.typname = 'place_category' and e.enumlabel = 'ski'
    ) then
      alter type public.place_category add value 'ski';
    end if;

    if not exists (
      select 1
      from pg_enum e
      join pg_type t on t.oid = e.enumtypid
      where t.typname = 'place_category' and e.enumlabel = 'waterfall'
    ) then
      alter type public.place_category add value 'waterfall';
    end if;

    if not exists (
      select 1
      from pg_enum e
      join pg_type t on t.oid = e.enumtypid
      where t.typname = 'place_category' and e.enumlabel = 'canyon'
    ) then
      alter type public.place_category add value 'canyon';
    end if;
  end if;
end $$;

do $$
begin
  if exists (
    select 1
    from pg_type
    where typnamespace = 'public'::regnamespace
      and typname = 'persona_mode'
  ) then
    if not exists (
      select 1
      from pg_enum e
      join pg_type t on t.oid = e.enumtypid
      where t.typname = 'persona_mode' and e.enumlabel = 'foodie'
    ) then
      alter type public.persona_mode add value 'foodie';
    end if;
  end if;
end $$;

alter table if exists public.districts
  add column if not exists bbox jsonb;

alter table if exists public.places
  add column if not exists source_kind public.source_kind not null default 'curated',
  add column if not exists source_url text,
  add column if not exists website text,
  add column if not exists phone text,
  add column if not exists opening_hours_json jsonb,
  add column if not exists google_place_id text,
  add column if not exists google_rating real,
  add column if not exists google_review_count int,
  add column if not exists google_price_level int,
  add column if not exists google_types text[] not null default '{}',
  add column if not exists google_last_sync timestamptz,
  add column if not exists google_photo_refs text[] not null default '{}',
  add column if not exists osm_type text,
  add column if not exists osm_id bigint,
  add column if not exists osm_tags jsonb,
  add column if not exists osm_last_sync timestamptz;

alter table if exists public.places
  alter column popularity_score set default 0;

alter table if exists public.places
  drop constraint if exists places_google_review_count_check;

alter table if exists public.places
  add constraint places_google_review_count_check
  check (google_review_count is null or google_review_count >= 0);

alter table if exists public.places
  drop constraint if exists places_google_price_level_check;

alter table if exists public.places
  add constraint places_google_price_level_check
  check (google_price_level is null or google_price_level between 0 and 4);

create unique index if not exists places_google_place_id_key
on public.places (google_place_id)
where google_place_id is not null;

create unique index if not exists places_osm_identity_key
on public.places (osm_type, osm_id)
where osm_type is not null and osm_id is not null;

create index if not exists places_source_kind_idx on public.places(source_kind);
create index if not exists places_google_rating_idx on public.places(google_rating desc, google_review_count desc);

delete from public.place_media pm
using public.place_media pm2
where pm.place_id = pm2.place_id
  and pm.storage_path = pm2.storage_path
  and pm.ctid > pm2.ctid;

create unique index if not exists place_media_place_path_uidx
on public.place_media(place_id, storage_path);
create index if not exists place_media_place_sort_idx
on public.place_media(place_id, sort_order);

alter table if exists public.place_media
  add column if not exists source_kind public.source_kind not null default 'curated';

update public.place_media
set source_kind = case
  when lower(coalesce(source, '')) like '%google%' then 'google'::public.source_kind
  when lower(coalesce(source, '')) like '%osm%' then 'osm'::public.source_kind
  else 'curated'::public.source_kind
end
where source_kind = 'curated'::public.source_kind;

create table if not exists public.district_ingest_jobs (
  id uuid primary key default gen_random_uuid(),
  province_id uuid not null references public.provinces(id) on delete cascade,
  district_id uuid not null references public.districts(id) on delete cascade,
  status text not null default 'queued' check (status in ('queued', 'running', 'done', 'failed')),
  last_error text,
  attempts int not null default 0,
  next_run_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (district_id)
);

create index if not exists district_ingest_jobs_status_next_run_idx
on public.district_ingest_jobs (status, next_run_at);

drop trigger if exists trg_district_ingest_jobs_updated_at on public.district_ingest_jobs;
create trigger trg_district_ingest_jobs_updated_at
before update on public.district_ingest_jobs
for each row execute function public.set_updated_at();

alter table if exists public.place_reviews
  add column if not exists flags text[] not null default '{}';

update public.place_reviews
set flags = case
  when coalesce(array_length(flags, 1), 0) > 0 then flags
  when coalesce(array_length(quick_flags, 1), 0) > 0 then quick_flags
  else '{}'::text[]
end;

alter table if exists public.place_reviews
  alter column comment_short drop not null;

alter table if exists public.place_reviews
  drop constraint if exists place_reviews_flags_allowed_check;

alter table if exists public.place_reviews
  add constraint place_reviews_flags_allowed_check
  check (
    flags <@ array[
      'crowded',
      'family',
      'quiet',
      'photo_spot',
      'budget',
      'sunset_worthy'
    ]::text[]
  );

alter table if exists public.profiles enable row level security;
alter table if exists public.provinces enable row level security;
alter table if exists public.districts enable row level security;
alter table if exists public.places enable row level security;
alter table if exists public.place_details enable row level security;
alter table if exists public.place_media enable row level security;
alter table if exists public.place_reviews enable row level security;
alter table if exists public.trips enable row level security;
alter table if exists public.trip_days enable row level security;
alter table if exists public.trip_stops enable row level security;
alter table if exists public.trip_shares enable row level security;
alter table if exists public.district_ingest_jobs enable row level security;

drop policy if exists "public_read_provinces" on public.provinces;
create policy "public_read_provinces"
on public.provinces
for select
to anon, authenticated
using (true);

drop policy if exists "public_read_districts" on public.districts;
create policy "public_read_districts"
on public.districts
for select
to anon, authenticated
using (true);

drop policy if exists "public_read_places" on public.places;
create policy "public_read_places"
on public.places
for select
to anon, authenticated
using (true);

drop policy if exists "public_read_place_details" on public.place_details;
create policy "public_read_place_details"
on public.place_details
for select
to anon, authenticated
using (true);

drop policy if exists "public_read_place_media" on public.place_media;
create policy "public_read_place_media"
on public.place_media
for select
to anon, authenticated
using (true);

drop policy if exists "place_reviews_public_select" on public.place_reviews;
create policy "place_reviews_public_select"
on public.place_reviews
for select
to anon, authenticated
using (true);

drop policy if exists "place_reviews_auth_insert" on public.place_reviews;
create policy "place_reviews_auth_insert"
on public.place_reviews
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "place_reviews_owner_or_admin_update" on public.place_reviews;
create policy "place_reviews_owner_or_admin_update"
on public.place_reviews
for update
to authenticated
using (auth.uid() = user_id or public.is_admin(auth.uid()))
with check (auth.uid() = user_id or public.is_admin(auth.uid()));

drop policy if exists "place_reviews_owner_or_admin_delete" on public.place_reviews;
create policy "place_reviews_owner_or_admin_delete"
on public.place_reviews
for delete
to authenticated
using (auth.uid() = user_id or public.is_admin(auth.uid()));

drop policy if exists "trips_owner_select" on public.trips;
create policy "trips_owner_select"
on public.trips
for select
to authenticated
using (user_id = auth.uid());

drop policy if exists "trips_owner_insert" on public.trips;
create policy "trips_owner_insert"
on public.trips
for insert
to authenticated
with check (user_id = auth.uid());

drop policy if exists "trips_owner_update" on public.trips;
create policy "trips_owner_update"
on public.trips
for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists "trips_owner_delete" on public.trips;
create policy "trips_owner_delete"
on public.trips
for delete
to authenticated
using (user_id = auth.uid());

drop policy if exists "trip_days_owner_all" on public.trip_days;
create policy "trip_days_owner_all"
on public.trip_days
for all
to authenticated
using (
  exists (
    select 1
    from public.trips t
    where t.id = trip_days.trip_id
      and t.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1
    from public.trips t
    where t.id = trip_days.trip_id
      and t.user_id = auth.uid()
  )
);

drop policy if exists "trip_stops_owner_all" on public.trip_stops;
create policy "trip_stops_owner_all"
on public.trip_stops
for all
to authenticated
using (
  exists (
    select 1
    from public.trip_days td
    join public.trips t on t.id = td.trip_id
    where td.id = trip_stops.trip_day_id
      and t.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1
    from public.trip_days td
    join public.trips t on t.id = td.trip_id
    where td.id = trip_stops.trip_day_id
      and t.user_id = auth.uid()
  )
);

drop policy if exists "trip_shares_owner_select" on public.trip_shares;
create policy "trip_shares_owner_select"
on public.trip_shares
for select
to authenticated
using (
  exists (
    select 1
    from public.trips t
    where t.id = trip_shares.trip_id
      and t.user_id = auth.uid()
  )
);

drop policy if exists "trip_shares_owner_insert" on public.trip_shares;
create policy "trip_shares_owner_insert"
on public.trip_shares
for insert
to authenticated
with check (
  exists (
    select 1
    from public.trips t
    where t.id = trip_shares.trip_id
      and t.user_id = auth.uid()
  )
);

drop policy if exists "trip_shares_owner_update" on public.trip_shares;
create policy "trip_shares_owner_update"
on public.trip_shares
for update
to authenticated
using (
  exists (
    select 1
    from public.trips t
    where t.id = trip_shares.trip_id
      and t.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1
    from public.trips t
    where t.id = trip_shares.trip_id
      and t.user_id = auth.uid()
  )
);

drop policy if exists "trip_shares_owner_delete" on public.trip_shares;
create policy "trip_shares_owner_delete"
on public.trip_shares
for delete
to authenticated
using (
  exists (
    select 1
    from public.trips t
    where t.id = trip_shares.trip_id
      and t.user_id = auth.uid()
  )
);

drop policy if exists "district_ingest_jobs_admin_select" on public.district_ingest_jobs;
create policy "district_ingest_jobs_admin_select"
on public.district_ingest_jobs
for select
to authenticated
using (public.is_admin(auth.uid()));

drop policy if exists "district_ingest_jobs_admin_insert" on public.district_ingest_jobs;
create policy "district_ingest_jobs_admin_insert"
on public.district_ingest_jobs
for insert
to authenticated
with check (public.is_admin(auth.uid()));

drop policy if exists "district_ingest_jobs_admin_update" on public.district_ingest_jobs;
create policy "district_ingest_jobs_admin_update"
on public.district_ingest_jobs
for update
to authenticated
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

drop view if exists public.place_stats cascade;
create view public.place_stats
with (security_invoker = on)
as
with base as (
  select
    r.place_id,
    round(avg(r.rating)::numeric, 2) as avg_rating,
    count(*)::int as review_count,
    count(*) filter (where r.flags && array['crowded']::text[])::int as crowded_count,
    count(*) filter (where r.flags && array['family']::text[])::int as family_count,
    count(*) filter (where r.flags && array['photo_spot']::text[])::int as photo_spot_count,
    count(*) filter (where r.flags && array['sunset_worthy']::text[])::int as sunset_worthy_count
  from public.place_reviews r
  group by r.place_id
)
select
  p.id as place_id,
  coalesce(b.avg_rating, p.google_rating::numeric, 0::numeric) as avg_rating,
  (coalesce(b.review_count, 0) + coalesce(p.google_review_count, 0))::int as review_count,
  coalesce(b.crowded_count, 0)::int as crowded_count,
  coalesce(b.family_count, 0)::int as family_count,
  coalesce(b.photo_spot_count, 0)::int as photo_spot_count,
  coalesce(b.sunset_worthy_count, 0)::int as sunset_worthy_count
from public.places p
left join base b on b.place_id = p.id;

grant select on public.place_stats to anon, authenticated;

drop view if exists public.community_place_stats cascade;
create view public.community_place_stats
with (security_invoker = on)
as
select
  r.place_id,
  round(avg(r.rating)::numeric, 2) as avg_rating,
  count(*)::int as review_count
from public.place_reviews r
group by r.place_id;

grant select on public.community_place_stats to anon, authenticated;

create or replace function public.get_place_stats(p_place_id uuid)
returns jsonb
language sql
stable
security invoker
as $$
  with stat as (
    select
      place_id,
      avg_rating,
      review_count,
      crowded_count,
      family_count,
      photo_spot_count,
      sunset_worthy_count
    from public.place_stats
    where place_id = p_place_id
  ),
  recent as (
    select jsonb_agg(
      jsonb_build_object(
        'rating', r.rating,
        'flags', r.flags,
        'comment_short', r.comment_short,
        'created_at', r.created_at
      )
      order by r.created_at desc
    ) as items
    from (
      select rating, flags, comment_short, created_at
      from public.place_reviews
      where place_id = p_place_id
      order by created_at desc
      limit 8
    ) r
  )
  select jsonb_build_object(
    'place_id', p_place_id,
    'avg_rating', coalesce((select avg_rating from stat), 0),
    'review_count', coalesce((select review_count from stat), 0),
    'crowded_count', coalesce((select crowded_count from stat), 0),
    'family_count', coalesce((select family_count from stat), 0),
    'photo_spot_count', coalesce((select photo_spot_count from stat), 0),
    'sunset_worthy_count', coalesce((select sunset_worthy_count from stat), 0),
    'recent_reviews', coalesce((select items from recent), '[]'::jsonb)
  );
$$;

grant execute on function public.get_place_stats(uuid) to anon, authenticated;

create or replace function public.nearby_places_core_rpc(
  p_lat double precision,
  p_lng double precision,
  p_radius_m integer,
  p_province_id uuid default null,
  p_district_id uuid default null,
  p_categories public.place_category[] default null,
  p_tags text[] default null,
  p_free_only boolean default false,
  p_min_rating numeric default null,
  p_limit integer default 50
)
returns table (
  id uuid,
  province_id uuid,
  district_id uuid,
  name text,
  slug citext,
  category public.place_category,
  short_summary text,
  best_time public.best_time,
  duration_min int,
  tags text[],
  popularity_score int,
  is_free boolean,
  source_kind public.source_kind,
  source_url text,
  google_rating real,
  google_review_count int,
  rating numeric,
  review_count int,
  distance_m double precision,
  lat double precision,
  lng double precision,
  image_path text,
  image_source_kind public.source_kind
)
language sql
stable
security invoker
as $$
  with origin as (
    select st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography as g
  ), ranked as (
    select
      p.id,
      p.province_id,
      p.district_id,
      p.name,
      p.slug,
      p.category,
      p.short_summary,
      p.best_time,
      p.duration_min,
      p.tags,
      p.popularity_score,
      p.is_free,
      p.source_kind,
      p.source_url,
      p.google_rating,
      p.google_review_count,
      coalesce(p.google_rating::numeric, ps.avg_rating, 0::numeric) as effective_rating,
      coalesce(ps.review_count, 0) as effective_review_count,
      st_distance(p.geog, o.g) as distance_m,
      st_y(p.geog::geometry) as lat,
      st_x(p.geog::geometry) as lng,
      pm.storage_path as image_path,
      coalesce(pm.source_kind, 'curated'::public.source_kind) as image_source_kind
    from public.places p
    cross join origin o
    left join public.place_stats ps on ps.place_id = p.id
    left join lateral (
      select m.storage_path, m.source_kind
      from public.place_media m
      where m.place_id = p.id
      order by m.sort_order asc, m.id asc
      limit 1
    ) pm on true
    where st_dwithin(p.geog, o.g, p_radius_m)
      and (p_province_id is null or p.province_id = p_province_id)
      and (p_district_id is null or p.district_id = p_district_id)
      and (
        p_categories is null
        or coalesce(array_length(p_categories, 1), 0) = 0
        or p.category = any(p_categories)
      )
      and (
        p_tags is null
        or coalesce(array_length(p_tags, 1), 0) = 0
        or p.tags && p_tags
      )
      and (not p_free_only or p.is_free = true)
      and (
        p_min_rating is null
        or coalesce(p.google_rating::numeric, ps.avg_rating, 0::numeric) >= p_min_rating
      )
  )
  select
    r.id,
    r.province_id,
    r.district_id,
    r.name,
    r.slug,
    r.category,
    r.short_summary,
    r.best_time,
    r.duration_min,
    r.tags,
    r.popularity_score,
    r.is_free,
    r.source_kind,
    r.source_url,
    r.google_rating,
    r.google_review_count,
    r.effective_rating,
    r.effective_review_count,
    r.distance_m,
    r.lat,
    r.lng,
    r.image_path,
    r.image_source_kind
  from ranked r
  order by
    case when r.category in ('food', 'cafe', 'lodging') then 0 else 1 end asc,
    case when r.category in ('food', 'cafe', 'lodging') then coalesce(r.google_rating, 0) end desc,
    case when r.category in ('food', 'cafe', 'lodging') then coalesce(r.google_review_count, 0) end desc,
    case when r.category in ('food', 'cafe', 'lodging') then r.distance_m end asc,
    case when r.category not in ('food', 'cafe', 'lodging') then r.popularity_score end desc,
    case when r.category not in ('food', 'cafe', 'lodging') then r.distance_m end asc,
    r.id asc
  limit greatest(1, least(50, p_limit));
$$;

grant execute on function public.nearby_places_core_rpc(
  double precision,
  double precision,
  integer,
  uuid,
  uuid,
  public.place_category[],
  text[],
  boolean,
  numeric,
  integer
) to anon, authenticated;

create or replace function public.next_nearest_place_rpc(
  p_place_ids uuid[],
  p_lat double precision,
  p_lng double precision
)
returns table (
  place_id uuid,
  distance_m double precision
)
language sql
stable
security invoker
as $$
  with origin as (
    select st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography as g
  )
  select
    p.id as place_id,
    st_distance(p.geog, o.g) as distance_m
  from public.places p
  cross join origin o
  where p.id = any(p_place_ids)
  order by p.geog <-> o.g, p.id asc
  limit 1;
$$;

grant execute on function public.next_nearest_place_rpc(uuid[], double precision, double precision) to anon, authenticated;

create or replace function public.claim_district_ingest_jobs(p_limit integer default 5)
returns setof public.district_ingest_jobs
language plpgsql
security definer
set search_path = public
as $$
begin
  return query
  with candidate as (
    select j.id
    from public.district_ingest_jobs j
    where j.status in ('queued', 'failed')
      and j.next_run_at <= now()
    order by j.next_run_at asc, j.created_at asc
    limit greatest(1, least(50, coalesce(p_limit, 5)))
    for update skip locked
  )
  update public.district_ingest_jobs j
  set status = 'running',
      updated_at = now()
  where j.id in (select id from candidate)
  returning j.*;
end;
$$;

grant execute on function public.claim_district_ingest_jobs(integer) to authenticated;

insert into storage.buckets (id, name, public)
values ('public-media', 'public-media', true)
on conflict (id) do update
set public = excluded.public;
