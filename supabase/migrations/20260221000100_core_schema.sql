-- Core schema for Routevia
create extension if not exists pgcrypto;
create extension if not exists citext;
create extension if not exists postgis;

create type public.place_category as enum (
  'museum',
  'historical',
  'nature',
  'beach',
  'viewpoint',
  'market',
  'cafe',
  'food',
  'activity'
);

create type public.best_time as enum ('morning', 'day', 'sunset', 'night');
create type public.transport_mode as enum ('walk', 'transit', 'car', 'bike');
create type public.pace as enum ('slow', 'medium', 'fast');
create type public.persona_mode as enum ('relax', 'romantic', 'family', 'budget', 'photo');
create type public.profile_role as enum ('user', 'admin');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  role public.profile_role not null default 'user',
  created_at timestamptz not null default now()
);

create table public.provinces (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  plate_no int not null unique check (plate_no between 1 and 81),
  slug citext not null unique,
  center_geog geography(point, 4326) not null,
  created_at timestamptz not null default now()
);

create table public.districts (
  id uuid primary key default gen_random_uuid(),
  province_id uuid not null references public.provinces(id) on delete cascade,
  name text not null,
  slug citext not null,
  center_geog geography(point, 4326) not null,
  created_at timestamptz not null default now(),
  unique (province_id, slug)
);

create table public.places (
  id uuid primary key default gen_random_uuid(),
  province_id uuid not null references public.provinces(id) on delete cascade,
  district_id uuid references public.districts(id) on delete set null,
  name text not null,
  slug citext not null,
  category public.place_category not null,
  geog geography(point, 4326) not null,
  short_summary text not null,
  best_time public.best_time not null default 'day',
  duration_min int not null check (duration_min between 15 and 240),
  tags text[] not null default '{}',
  popularity_score int not null default 50 check (popularity_score between 0 and 1000),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (province_id, slug),
  check (char_length(short_summary) <= 160),
  check (coalesce(array_length(tags, 1), 0) <= 10)
);

create table public.place_details (
  place_id uuid primary key references public.places(id) on delete cascade,
  history_bullets text[] not null default '{}',
  eat_drink_bullets text[] not null default '{}',
  tips_bullets text[] not null default '{}',
  check (coalesce(array_length(history_bullets, 1), 0) <= 3),
  check (coalesce(array_length(eat_drink_bullets, 1), 0) <= 3),
  check (coalesce(array_length(tips_bullets, 1), 0) <= 4)
);

create table public.place_media (
  id uuid primary key default gen_random_uuid(),
  place_id uuid not null references public.places(id) on delete cascade,
  storage_path text not null,
  source text,
  sort_order int not null default 0
);

create table public.trips (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  province_id uuid not null references public.provinces(id) on delete restrict,
  days int not null check (days between 1 and 7),
  transport_mode public.transport_mode not null,
  pace public.pace not null,
  persona_mode public.persona_mode not null,
  preferences text[] not null default '{}',
  created_at timestamptz not null default now()
);

create table public.trip_days (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips(id) on delete cascade,
  day_number int not null check (day_number between 1 and 7),
  unique (trip_id, day_number)
);

create table public.trip_stops (
  id uuid primary key default gen_random_uuid(),
  trip_day_id uuid not null references public.trip_days(id) on delete cascade,
  place_id uuid not null references public.places(id) on delete restrict,
  order_index int not null check (order_index > 0),
  arrival_time time not null,
  duration_min int not null check (duration_min between 10 and 360),
  transport_mode public.transport_mode not null,
  unique (trip_day_id, order_index)
);

create table public.trip_shares (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips(id) on delete cascade,
  share_token text not null unique,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create index places_province_idx on public.places (province_id);
create index places_district_idx on public.places (district_id);
create index places_category_idx on public.places (category);
create index places_tags_gin_idx on public.places using gin (tags);
create index places_geog_gist_idx on public.places using gist (geog);
create index trip_stops_day_order_idx on public.trip_stops (trip_day_id, order_index);
create index trip_shares_token_idx on public.trip_shares (share_token);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger trg_places_updated_at
before update on public.places
for each row execute function public.set_updated_at();

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, new.raw_user_meta_data ->> 'display_name')
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();
