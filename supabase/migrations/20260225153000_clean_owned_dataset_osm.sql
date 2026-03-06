create extension if not exists pgcrypto;
create extension if not exists citext;
create extension if not exists postgis;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'place_category') THEN
    CREATE TYPE public.place_category AS ENUM ('museum','historical','nature','beach','viewpoint','market','cafe','food','activity');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'best_time') THEN
    CREATE TYPE public.best_time AS ENUM ('morning','day','sunset','night');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'transport_mode') THEN
    CREATE TYPE public.transport_mode AS ENUM ('walk','transit','car','bike');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'pace') THEN
    CREATE TYPE public.pace AS ENUM ('slow','medium','fast');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'persona_mode') THEN
    CREATE TYPE public.persona_mode AS ENUM ('relax','romantic','family','budget','photo');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'profile_role') THEN
    CREATE TYPE public.profile_role AS ENUM ('user','admin');
  END IF;
END$$;

alter table if exists public.profiles
  add column if not exists role public.profile_role not null default 'user';

create table if not exists public.places_clean (
  id uuid primary key default gen_random_uuid(),
  province_id uuid not null references public.provinces(id) on delete cascade,
  district_id uuid null references public.districts(id) on delete set null,
  name text not null,
  slug citext not null,
  category public.place_category not null,
  geog geography(point,4326) not null,
  short_summary text not null check (char_length(short_summary) <= 160),
  best_time public.best_time not null default 'day',
  duration_min int not null check (duration_min between 15 and 240),
  tags text[] not null default '{}',
  popularity_score int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (province_id, slug)
);

create index if not exists places_clean_province_idx on public.places_clean(province_id);
create index if not exists places_clean_district_idx on public.places_clean(district_id);
create index if not exists places_clean_category_idx on public.places_clean(category);
create index if not exists places_clean_tags_gin on public.places_clean using gin(tags);
create index if not exists places_clean_geog_gist on public.places_clean using gist(geog);

create table if not exists public.place_details_clean (
  place_id uuid primary key references public.places_clean(id) on delete cascade,
  history_bullets text[] not null default '{}',
  eat_drink_bullets text[] not null default '{}',
  tips_bullets text[] not null default '{}',
  constraint place_details_clean_history_len check (coalesce(array_length(history_bullets, 1), 0) <= 3),
  constraint place_details_clean_eat_len check (coalesce(array_length(eat_drink_bullets, 1), 0) <= 3),
  constraint place_details_clean_tips_len check (coalesce(array_length(tips_bullets, 1), 0) <= 4)
);

create table if not exists public.place_media_clean (
  id uuid primary key default gen_random_uuid(),
  place_id uuid not null references public.places_clean(id) on delete cascade,
  storage_path text not null,
  source text not null check (source in ('user_upload','curated','placeholder','open_license')),
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

create index if not exists place_media_clean_place_idx on public.place_media_clean(place_id, sort_order);

create table if not exists public.place_reviews_clean (
  id uuid primary key default gen_random_uuid(),
  place_id uuid not null references public.places_clean(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  rating int not null check (rating between 1 and 5),
  comment text,
  created_at timestamptz not null default now(),
  unique (place_id, user_id)
);

create table if not exists public.place_rating_summary_clean (
  place_id uuid primary key references public.places_clean(id) on delete cascade,
  avg_rating numeric(3,2) not null default 0,
  review_count int not null default 0
);

create table if not exists public.trips_clean (
  id uuid primary key default gen_random_uuid(),
  user_id uuid null references auth.users(id) on delete cascade,
  province_id uuid not null references public.provinces(id),
  days int not null check (days between 1 and 7),
  transport_mode public.transport_mode not null,
  pace public.pace not null default 'medium',
  persona_mode public.persona_mode not null default 'relax',
  preferences text[] not null default '{}',
  created_at timestamptz not null default now()
);

create table if not exists public.trip_days_clean (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips_clean(id) on delete cascade,
  day_number int not null,
  unique (trip_id, day_number)
);

create table if not exists public.trip_stops_clean (
  id uuid primary key default gen_random_uuid(),
  trip_day_id uuid not null references public.trip_days_clean(id) on delete cascade,
  place_id uuid not null references public.places_clean(id) on delete restrict,
  order_index int not null,
  arrival_time time not null,
  duration_min int not null check (duration_min between 15 and 240),
  transport_mode public.transport_mode not null,
  note text
);

create table if not exists public.trip_shares_clean (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips_clean(id) on delete cascade,
  share_token text not null unique,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.raw_place_links_clean (
  id uuid primary key default gen_random_uuid(),
  raw_table text not null,
  raw_pk text not null,
  clean_place_id uuid not null references public.places_clean(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique(raw_table, raw_pk),
  unique(clean_place_id)
);

create or replace function public.touch_updated_at_clean()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists trg_places_clean_updated_at on public.places_clean;
create trigger trg_places_clean_updated_at
before update on public.places_clean
for each row execute function public.touch_updated_at_clean();

create or replace function public.refresh_place_rating_summary_clean(p_place_id uuid)
returns void
language plpgsql
as $$
declare
  v_avg numeric(3,2);
  v_count int;
begin
  select coalesce(avg(rating)::numeric(3,2), 0), count(*)::int
  into v_avg, v_count
  from public.place_reviews_clean
  where place_id = p_place_id;

  insert into public.place_rating_summary_clean(place_id, avg_rating, review_count)
  values (p_place_id, v_avg, v_count)
  on conflict (place_id) do update
  set avg_rating = excluded.avg_rating,
      review_count = excluded.review_count;
end;
$$;

create or replace function public.place_reviews_clean_summary_trigger()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'DELETE' then
    perform public.refresh_place_rating_summary_clean(old.place_id);
  else
    perform public.refresh_place_rating_summary_clean(new.place_id);
  end if;
  return null;
end;
$$;

drop trigger if exists trg_place_reviews_clean_summary on public.place_reviews_clean;
create trigger trg_place_reviews_clean_summary
after insert or update or delete on public.place_reviews_clean
for each row execute function public.place_reviews_clean_summary_trigger();

create or replace function public.nearby_places_clean_rpc(
  p_lat double precision,
  p_lng double precision,
  p_radius_m integer default 10000,
  p_province_id uuid default null,
  p_district_id uuid default null,
  p_categories text[] default null,
  p_tags text[] default null,
  p_limit integer default 200
)
returns table (
  id uuid,
  province_id uuid,
  district_id uuid,
  province_name text,
  district_name text,
  name text,
  slug text,
  category text,
  short_summary text,
  best_time text,
  duration_min int,
  tags text[],
  popularity_score int,
  avg_rating numeric(3,2),
  review_count int,
  distance_m double precision,
  lat double precision,
  lng double precision,
  image_path text
)
language sql
stable
as $$
  with q as (
    select
      p.id,
      p.province_id,
      p.district_id,
      pr.name as province_name,
      d.name as district_name,
      p.name,
      p.slug::text as slug,
      p.category::text as category,
      p.short_summary,
      p.best_time::text as best_time,
      p.duration_min,
      p.tags,
      p.popularity_score,
      coalesce(rs.avg_rating, 0)::numeric(3,2) as avg_rating,
      coalesce(rs.review_count, 0) as review_count,
      st_distance(
        p.geog,
        st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography
      ) as distance_m,
      st_y(p.geog::geometry) as lat,
      st_x(p.geog::geometry) as lng,
      (
        select pm.storage_path
        from public.place_media_clean pm
        where pm.place_id = p.id
        order by pm.sort_order asc, pm.created_at asc
        limit 1
      ) as image_path
    from public.places_clean p
    join public.provinces pr on pr.id = p.province_id
    left join public.districts d on d.id = p.district_id
    left join public.place_rating_summary_clean rs on rs.place_id = p.id
    where st_dwithin(
      p.geog,
      st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography,
      greatest(500, least(p_radius_m, 40000))
    )
    and (p_province_id is null or p.province_id = p_province_id)
    and (p_district_id is null or p.district_id = p_district_id)
    and (p_categories is null or coalesce(array_length(p_categories, 1), 0) = 0 or p.category::text = any(p_categories))
    and (p_tags is null or coalesce(array_length(p_tags, 1), 0) = 0 or p.tags && p_tags)
  )
  select *
  from q
  order by distance_m asc, avg_rating desc, review_count desc, popularity_score desc
  limit greatest(1, least(p_limit, 200));
$$;

alter table if exists public.places_clean enable row level security;
alter table if exists public.place_details_clean enable row level security;
alter table if exists public.place_media_clean enable row level security;
alter table if exists public.place_reviews_clean enable row level security;
alter table if exists public.place_rating_summary_clean enable row level security;
alter table if exists public.trips_clean enable row level security;
alter table if exists public.trip_days_clean enable row level security;
alter table if exists public.trip_stops_clean enable row level security;
alter table if exists public.trip_shares_clean enable row level security;
alter table if exists public.raw_place_links_clean enable row level security;

-- public read
DROP POLICY IF EXISTS "places_clean_public_read" ON public.places_clean;
create policy "places_clean_public_read"
on public.places_clean for select
using (true);

DROP POLICY IF EXISTS "place_details_clean_public_read" ON public.place_details_clean;
create policy "place_details_clean_public_read"
on public.place_details_clean for select
using (true);

DROP POLICY IF EXISTS "place_media_clean_public_read" ON public.place_media_clean;
create policy "place_media_clean_public_read"
on public.place_media_clean for select
using (true);

DROP POLICY IF EXISTS "place_rating_summary_clean_public_read" ON public.place_rating_summary_clean;
create policy "place_rating_summary_clean_public_read"
on public.place_rating_summary_clean for select
using (true);

DROP POLICY IF EXISTS "place_reviews_clean_public_read" ON public.place_reviews_clean;
create policy "place_reviews_clean_public_read"
on public.place_reviews_clean for select
using (true);

DROP POLICY IF EXISTS "place_reviews_clean_owner_write" ON public.place_reviews_clean;
create policy "place_reviews_clean_owner_write"
on public.place_reviews_clean
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

DROP POLICY IF EXISTS "trips_clean_owner_crud" ON public.trips_clean;
create policy "trips_clean_owner_crud"
on public.trips_clean
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

DROP POLICY IF EXISTS "trip_days_clean_owner_crud" ON public.trip_days_clean;
create policy "trip_days_clean_owner_crud"
on public.trip_days_clean
for all
using (
  exists (
    select 1 from public.trips_clean t
    where t.id = trip_days_clean.trip_id and t.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from public.trips_clean t
    where t.id = trip_days_clean.trip_id and t.user_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "trip_stops_clean_owner_crud" ON public.trip_stops_clean;
create policy "trip_stops_clean_owner_crud"
on public.trip_stops_clean
for all
using (
  exists (
    select 1
    from public.trip_days_clean td
    join public.trips_clean t on t.id = td.trip_id
    where td.id = trip_stops_clean.trip_day_id and t.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1
    from public.trip_days_clean td
    join public.trips_clean t on t.id = td.trip_id
    where td.id = trip_stops_clean.trip_day_id and t.user_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "trip_shares_clean_owner_crud" ON public.trip_shares_clean;
create policy "trip_shares_clean_owner_crud"
on public.trip_shares_clean
for all
using (
  exists (
    select 1 from public.trips_clean t
    where t.id = trip_shares_clean.trip_id and t.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from public.trips_clean t
    where t.id = trip_shares_clean.trip_id and t.user_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "raw_place_links_clean_admin_only" ON public.raw_place_links_clean;
create policy "raw_place_links_clean_admin_only"
on public.raw_place_links_clean
for all
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

DO $$
DECLARE
  r record;
BEGIN
  FOR r IN
    SELECT n.nspname as table_schema, c.relname as table_name
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relkind = 'r'
      AND n.nspname = 'public'
      AND EXISTS (
        SELECT 1
        FROM information_schema.columns ic
        WHERE ic.table_schema = n.nspname
          AND ic.table_name = c.relname
          AND (
            ic.column_name LIKE 'google_%'
            OR ic.column_name IN ('google_place_id', 'source_place_id', 'raw_hash')
          )
      )
  LOOP
    EXECUTE format('ALTER TABLE %I.%I ENABLE ROW LEVEL SECURITY', r.table_schema, r.table_name);
    EXECUTE format('DROP POLICY IF EXISTS raw_admin_only_policy ON %I.%I', r.table_schema, r.table_name);
    EXECUTE format('CREATE POLICY raw_admin_only_policy ON %I.%I FOR SELECT USING (public.is_admin(auth.uid()))', r.table_schema, r.table_name);
  END LOOP;
END$$;
