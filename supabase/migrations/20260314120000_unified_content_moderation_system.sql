begin;

create extension if not exists pgcrypto;

do $$
begin
  if not exists (
    select 1
    from pg_type
    where typname = 'moderation_status'
  ) then
    create type public.moderation_status as enum (
      'pending',
      'approved',
      'rejected',
      'needs_edit'
    );
  end if;

  if not exists (
    select 1
    from pg_type
    where typname = 'moderation_submission_type'
  ) then
    create type public.moderation_submission_type as enum (
      'place_submission',
      'story_submission',
      'photo_submission'
    );
  end if;

  if not exists (
    select 1
    from pg_type
    where typname = 'story_kind'
  ) then
    create type public.story_kind as enum (
      'story',
      'local_tip',
      'history_note',
      'hidden_feature'
    );
  end if;

  if not exists (
    select 1
    from pg_type
    where typname = 'place_image_kind'
  ) then
    create type public.place_image_kind as enum (
      'cover',
      'gallery',
      'community'
    );
  end if;
end
$$;

create or replace function public.touch_updated_at_generic()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create or replace function public.map_legacy_status(p_status text)
returns public.moderation_status
language sql
immutable
as $$
  select case lower(coalesce(trim(p_status), ''))
    when 'approved' then 'approved'::public.moderation_status
    when 'rejected' then 'rejected'::public.moderation_status
    when 'needs_edit' then 'needs_edit'::public.moderation_status
    when 'hidden' then 'rejected'::public.moderation_status
    else 'pending'::public.moderation_status
  end;
$$;

create table if not exists public.cities (
  id uuid primary key default gen_random_uuid(),
  legacy_province_id uuid unique references public.provinces(id) on delete set null,
  name text not null,
  slug citext not null unique,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  key text not null unique,
  label text not null,
  sort_order int not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.tags (
  id uuid primary key default gen_random_uuid(),
  slug citext not null unique,
  label text not null,
  usage_count int not null default 0 check (usage_count >= 0),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.place_images (
  id uuid primary key default gen_random_uuid(),
  place_id uuid not null references public.pois(id) on delete cascade,
  source_submission_id uuid,
  bucket text not null,
  object_path text not null,
  image_type public.place_image_kind not null default 'gallery',
  mime_type text,
  width int,
  height int,
  file_size_bytes int,
  alt_text text,
  sort_order int not null default 0,
  is_active boolean not null default true,
  is_published boolean not null default true,
  created_by uuid references auth.users(id) on delete set null,
  published_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  unique (place_id, bucket, object_path)
);

create table if not exists public.place_stories (
  id uuid primary key default gen_random_uuid(),
  place_id uuid not null references public.pois(id) on delete cascade,
  source_submission_id uuid unique,
  author_user_id uuid references auth.users(id) on delete set null,
  title text not null default '',
  story_kind public.story_kind not null default 'story',
  story_text text not null,
  admin_note text,
  is_published boolean not null default true,
  published_at timestamptz not null default now(),
  unpublished_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  check (char_length(title) <= 140),
  check (char_length(story_text) between 40 and 4000)
);

create table if not exists public.place_tag_map (
  place_id uuid not null references public.pois(id) on delete cascade,
  tag_id uuid not null references public.tags(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (place_id, tag_id)
);

create table if not exists public.featured_places (
  id uuid primary key default gen_random_uuid(),
  city_id uuid references public.cities(id) on delete set null,
  place_id uuid not null references public.pois(id) on delete cascade,
  title text,
  subtitle text,
  sort_order int not null default 0,
  is_active boolean not null default true,
  starts_at timestamptz,
  ends_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.weekly_routes (
  id uuid primary key default gen_random_uuid(),
  city_id uuid references public.cities(id) on delete set null,
  slug citext not null unique,
  title text not null,
  summary text not null default '',
  hero_bucket text,
  hero_object_path text,
  route_payload jsonb not null default '[]'::jsonb,
  is_published boolean not null default false,
  published_at timestamptz,
  starts_at timestamptz,
  ends_at timestamptz,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.user_place_submissions (
  id uuid primary key default gen_random_uuid(),
  legacy_place_suggestion_id uuid unique,
  user_id uuid not null references auth.users(id) on delete cascade,
  city_id uuid references public.cities(id) on delete set null,
  legacy_province_id uuid references public.provinces(id) on delete set null,
  legacy_district_id uuid references public.districts(id) on delete set null,
  place_name text not null,
  category_key text not null,
  tag_slugs text[] not null default '{}'::text[],
  short_note text not null default '',
  description text,
  source_url text,
  lat double precision,
  lng double precision,
  cover_bucket text,
  cover_object_path text,
  status public.moderation_status not null default 'pending',
  admin_note text,
  rejection_reason text,
  approved_place_id uuid references public.pois(id) on delete set null,
  reviewed_by uuid references auth.users(id) on delete set null,
  submitted_at timestamptz not null default now(),
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  check (char_length(place_name) between 3 and 180),
  check (char_length(short_note) <= 400)
);

create table if not exists public.user_story_submissions (
  id uuid primary key default gen_random_uuid(),
  legacy_place_story_submission_id uuid unique,
  user_id uuid not null references auth.users(id) on delete cascade,
  place_id uuid not null references public.pois(id) on delete cascade,
  title text not null default '',
  story_text text not null,
  story_kind public.story_kind not null default 'story',
  source_url text,
  asset_bucket text,
  asset_object_path text,
  status public.moderation_status not null default 'pending',
  admin_note text,
  rejection_reason text,
  approved_story_id uuid references public.place_stories(id) on delete set null,
  reviewed_by uuid references auth.users(id) on delete set null,
  submitted_at timestamptz not null default now(),
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  check (char_length(title) <= 140),
  check (char_length(story_text) between 40 and 4000)
);

create table if not exists public.user_photo_submissions (
  id uuid primary key default gen_random_uuid(),
  legacy_place_photo_id uuid unique,
  user_id uuid not null references auth.users(id) on delete cascade,
  place_id uuid not null references public.pois(id) on delete cascade,
  bucket text not null,
  object_path text not null,
  mime_type text,
  width int,
  height int,
  file_size_bytes int,
  caption text,
  status public.moderation_status not null default 'pending',
  admin_note text,
  rejection_reason text,
  approved_place_image_id uuid references public.place_images(id) on delete set null,
  reviewed_by uuid references auth.users(id) on delete set null,
  submitted_at timestamptz not null default now(),
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  unique (bucket, object_path)
);

create table if not exists public.moderation_queue (
  id uuid primary key default gen_random_uuid(),
  submission_type public.moderation_submission_type not null,
  submission_id uuid not null,
  user_id uuid not null references auth.users(id) on delete cascade,
  place_id uuid references public.pois(id) on delete cascade,
  city_id uuid references public.cities(id) on delete set null,
  status public.moderation_status not null,
  searchable_title text,
  searchable_excerpt text,
  bucket text,
  object_path text,
  admin_note text,
  rejection_reason text,
  queue_rank int not null default 100,
  submitted_at timestamptz not null default now(),
  reviewed_at timestamptz,
  reviewed_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (submission_type, submission_id)
);

create table if not exists public.admin_audit_logs (
  id uuid primary key default gen_random_uuid(),
  admin_user_id uuid references auth.users(id) on delete set null,
  action text not null,
  target_table text not null,
  target_id uuid,
  moderation_queue_id uuid references public.moderation_queue(id) on delete set null,
  old_data jsonb,
  new_data jsonb,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_cities_active_slug
  on public.cities(is_active, slug);
create index if not exists idx_categories_active_sort
  on public.categories(is_active, sort_order, key);
create index if not exists idx_tags_active_usage
  on public.tags(is_active, usage_count desc, slug);
create index if not exists idx_place_images_place_published_sort
  on public.place_images(place_id, is_published, is_active, image_type, sort_order, created_at desc)
  where deleted_at is null;
create index if not exists idx_place_stories_place_published_created
  on public.place_stories(place_id, is_published, created_at desc)
  where deleted_at is null;
create index if not exists idx_place_tag_map_tag_place
  on public.place_tag_map(tag_id, place_id);
create index if not exists idx_featured_places_city_active_sort
  on public.featured_places(city_id, is_active, sort_order);
create index if not exists idx_weekly_routes_city_publish
  on public.weekly_routes(city_id, is_published, starts_at desc)
  where deleted_at is null;
create index if not exists idx_user_place_submissions_user_status_created
  on public.user_place_submissions(user_id, status, created_at desc)
  where deleted_at is null;
create index if not exists idx_user_place_submissions_city_status_created
  on public.user_place_submissions(city_id, status, created_at desc)
  where deleted_at is null;
create index if not exists idx_user_story_submissions_user_status_created
  on public.user_story_submissions(user_id, status, created_at desc)
  where deleted_at is null;
create index if not exists idx_user_story_submissions_place_status_created
  on public.user_story_submissions(place_id, status, created_at desc)
  where deleted_at is null;
create index if not exists idx_user_photo_submissions_user_status_created
  on public.user_photo_submissions(user_id, status, created_at desc)
  where deleted_at is null;
create index if not exists idx_user_photo_submissions_place_status_created
  on public.user_photo_submissions(place_id, status, created_at desc)
  where deleted_at is null;
create index if not exists idx_moderation_queue_status_type_submitted
  on public.moderation_queue(status, submission_type, submitted_at desc);
create index if not exists idx_moderation_queue_place_status_submitted
  on public.moderation_queue(place_id, status, submitted_at desc);
create index if not exists idx_moderation_queue_user_status_submitted
  on public.moderation_queue(user_id, status, submitted_at desc);
create index if not exists idx_moderation_queue_search_title
  on public.moderation_queue using gin (to_tsvector('simple', coalesce(searchable_title, '') || ' ' || coalesce(searchable_excerpt, '')));
create index if not exists idx_admin_audit_logs_target_created
  on public.admin_audit_logs(target_table, target_id, created_at desc);
create index if not exists idx_admin_audit_logs_admin_created
  on public.admin_audit_logs(admin_user_id, created_at desc);

drop trigger if exists trg_cities_touch_updated_at on public.cities;
create trigger trg_cities_touch_updated_at
before update on public.cities
for each row execute function public.touch_updated_at_generic();

drop trigger if exists trg_categories_touch_updated_at on public.categories;
create trigger trg_categories_touch_updated_at
before update on public.categories
for each row execute function public.touch_updated_at_generic();

drop trigger if exists trg_tags_touch_updated_at on public.tags;
create trigger trg_tags_touch_updated_at
before update on public.tags
for each row execute function public.touch_updated_at_generic();

drop trigger if exists trg_place_images_touch_updated_at on public.place_images;
create trigger trg_place_images_touch_updated_at
before update on public.place_images
for each row execute function public.touch_updated_at_generic();

drop trigger if exists trg_place_stories_touch_updated_at on public.place_stories;
create trigger trg_place_stories_touch_updated_at
before update on public.place_stories
for each row execute function public.touch_updated_at_generic();

drop trigger if exists trg_featured_places_touch_updated_at on public.featured_places;
create trigger trg_featured_places_touch_updated_at
before update on public.featured_places
for each row execute function public.touch_updated_at_generic();

drop trigger if exists trg_weekly_routes_touch_updated_at on public.weekly_routes;
create trigger trg_weekly_routes_touch_updated_at
before update on public.weekly_routes
for each row execute function public.touch_updated_at_generic();

drop trigger if exists trg_user_place_submissions_touch_updated_at on public.user_place_submissions;
create trigger trg_user_place_submissions_touch_updated_at
before update on public.user_place_submissions
for each row execute function public.touch_updated_at_generic();

drop trigger if exists trg_user_story_submissions_touch_updated_at on public.user_story_submissions;
create trigger trg_user_story_submissions_touch_updated_at
before update on public.user_story_submissions
for each row execute function public.touch_updated_at_generic();

drop trigger if exists trg_user_photo_submissions_touch_updated_at on public.user_photo_submissions;
create trigger trg_user_photo_submissions_touch_updated_at
before update on public.user_photo_submissions
for each row execute function public.touch_updated_at_generic();

drop trigger if exists trg_moderation_queue_touch_updated_at on public.moderation_queue;
create trigger trg_moderation_queue_touch_updated_at
before update on public.moderation_queue
for each row execute function public.touch_updated_at_generic();

insert into public.cities (legacy_province_id, name, slug)
select p.id, p.name, p.slug
from public.provinces p
on conflict (legacy_province_id) do update
set name = excluded.name,
    slug = excluded.slug,
    updated_at = now();

insert into public.categories (key, label, sort_order)
values
  ('museum', 'Museum', 10),
  ('historical', 'Historical', 20),
  ('nature', 'Nature', 30),
  ('beach', 'Beach', 40),
  ('viewpoint', 'Viewpoint', 50),
  ('market', 'Market', 60),
  ('cafe', 'Cafe', 70),
  ('food', 'Food', 80),
  ('activity', 'Activity', 90),
  ('mall', 'Mall', 100),
  ('lodging', 'Lodging', 110)
on conflict (key) do update
set label = excluded.label,
    sort_order = excluded.sort_order,
    updated_at = now();

insert into public.tags (slug, label)
select distinct
  lower(trim(t.tag))::citext as slug,
  initcap(replace(lower(trim(t.tag)), '_', ' ')) as label
from (
  select unnest(coalesce(p.tags, '{}'::text[])) as tag
  from public.places_clean p
  union
  select unnest(coalesce(ps.suggested_tags, '{}'::text[])) as tag
  from public.place_suggestions ps
) t
where nullif(trim(t.tag), '') is not null
on conflict (slug) do update
set label = excluded.label;

insert into public.user_place_submissions (
  legacy_place_suggestion_id,
  user_id,
  city_id,
  legacy_province_id,
  legacy_district_id,
  place_name,
  category_key,
  tag_slugs,
  short_note,
  source_url,
  lat,
  lng,
  status,
  admin_note,
  reviewed_by,
  submitted_at,
  reviewed_at,
  created_at,
  updated_at
)
select
  ps.id,
  ps.user_id,
  c.id,
  ps.province_id,
  ps.district_id,
  ps.suggested_name,
  ps.suggested_category::text,
  coalesce(ps.suggested_tags, '{}'::text[]),
  ps.short_note,
  ps.source_url,
  ps.lat,
  ps.lng,
  public.map_legacy_status(ps.status),
  ps.admin_note,
  ps.reviewed_by,
  ps.created_at,
  ps.reviewed_at,
  ps.created_at,
  coalesce(ps.updated_at, ps.created_at)
from public.place_suggestions ps
left join public.cities c on c.legacy_province_id = ps.province_id
on conflict (legacy_place_suggestion_id) do nothing;

insert into public.user_story_submissions (
  legacy_place_story_submission_id,
  user_id,
  place_id,
  title,
  story_text,
  story_kind,
  status,
  admin_note,
  reviewed_by,
  submitted_at,
  reviewed_at,
  created_at,
  updated_at
)
select
  pss.id,
  pss.user_id,
  pss.place_id,
  pss.title,
  pss.story_text,
  pss.fact_type::public.story_kind,
  public.map_legacy_status(pss.status),
  pss.admin_note,
  pss.reviewed_by,
  pss.created_at,
  pss.reviewed_at,
  pss.created_at,
  coalesce(pss.updated_at, pss.created_at)
from public.place_story_submissions pss
on conflict (legacy_place_story_submission_id) do nothing;

insert into public.user_photo_submissions (
  legacy_place_photo_id,
  user_id,
  place_id,
  bucket,
  object_path,
  mime_type,
  width,
  height,
  file_size_bytes,
  status,
  admin_note,
  submitted_at,
  reviewed_at,
  created_at,
  updated_at
)
select
  pp.id,
  pp.user_id,
  pp.place_id,
  'place-photos',
  pp.storage_path,
  null,
  pp.width_px,
  pp.height_px,
  pp.file_size_bytes,
  public.map_legacy_status(pp.status),
  pp.moderation_note,
  pp.created_at,
  null,
  pp.created_at,
  coalesce(pp.updated_at, pp.created_at)
from public.place_photos pp
on conflict (legacy_place_photo_id) do nothing;

create or replace function public.sync_moderation_queue_from_submission()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_submission_type public.moderation_submission_type := tg_argv[0]::public.moderation_submission_type;
  v_submission_id uuid;
  v_user_id uuid;
  v_place_id uuid;
  v_city_id uuid;
  v_status public.moderation_status;
  v_title text;
  v_excerpt text;
  v_bucket text;
  v_object_path text;
  v_admin_note text;
  v_rejection_reason text;
  v_submitted_at timestamptz;
  v_reviewed_at timestamptz;
  v_reviewed_by uuid;
  v_rank int := 100;
begin
  if tg_table_name = 'user_place_submissions' then
    v_submission_id := new.id;
    v_user_id := new.user_id;
    v_place_id := new.approved_place_id;
    v_city_id := new.city_id;
    v_status := new.status;
    v_title := new.place_name;
    v_excerpt := coalesce(new.short_note, new.description);
    v_bucket := new.cover_bucket;
    v_object_path := new.cover_object_path;
    v_admin_note := new.admin_note;
    v_rejection_reason := new.rejection_reason;
    v_submitted_at := new.submitted_at;
    v_reviewed_at := new.reviewed_at;
    v_reviewed_by := new.reviewed_by;
    v_rank := 10;
  elsif tg_table_name = 'user_story_submissions' then
    v_submission_id := new.id;
    v_user_id := new.user_id;
    v_place_id := new.place_id;
    v_status := new.status;
    v_title := coalesce(nullif(trim(new.title), ''), initcap(new.story_kind::text));
    v_excerpt := left(new.story_text, 280);
    v_bucket := new.asset_bucket;
    v_object_path := new.asset_object_path;
    v_admin_note := new.admin_note;
    v_rejection_reason := new.rejection_reason;
    v_submitted_at := new.submitted_at;
    v_reviewed_at := new.reviewed_at;
    v_reviewed_by := new.reviewed_by;
    v_rank := 20;
  elsif tg_table_name = 'user_photo_submissions' then
    v_submission_id := new.id;
    v_user_id := new.user_id;
    v_place_id := new.place_id;
    v_status := new.status;
    v_title := 'Community photo';
    v_excerpt := coalesce(new.caption, new.object_path);
    v_bucket := new.bucket;
    v_object_path := new.object_path;
    v_admin_note := new.admin_note;
    v_rejection_reason := new.rejection_reason;
    v_submitted_at := new.submitted_at;
    v_reviewed_at := new.reviewed_at;
    v_reviewed_by := new.reviewed_by;
    v_rank := 30;
  else
    raise exception 'unsupported moderation source table: %', tg_table_name;
  end if;

  insert into public.moderation_queue (
    submission_type,
    submission_id,
    user_id,
    place_id,
    city_id,
    status,
    searchable_title,
    searchable_excerpt,
    bucket,
    object_path,
    admin_note,
    rejection_reason,
    queue_rank,
    submitted_at,
    reviewed_at,
    reviewed_by
  )
  values (
    v_submission_type,
    v_submission_id,
    v_user_id,
    v_place_id,
    v_city_id,
    v_status,
    v_title,
    v_excerpt,
    v_bucket,
    v_object_path,
    v_admin_note,
    v_rejection_reason,
    v_rank,
    coalesce(v_submitted_at, now()),
    v_reviewed_at,
    v_reviewed_by
  )
  on conflict (submission_type, submission_id) do update
  set
    user_id = excluded.user_id,
    place_id = excluded.place_id,
    city_id = excluded.city_id,
    status = excluded.status,
    searchable_title = excluded.searchable_title,
    searchable_excerpt = excluded.searchable_excerpt,
    bucket = excluded.bucket,
    object_path = excluded.object_path,
    admin_note = excluded.admin_note,
    rejection_reason = excluded.rejection_reason,
    queue_rank = excluded.queue_rank,
    submitted_at = excluded.submitted_at,
    reviewed_at = excluded.reviewed_at,
    reviewed_by = excluded.reviewed_by,
    updated_at = now();

  return new;
end;
$$;

drop trigger if exists trg_user_place_submissions_sync_queue on public.user_place_submissions;
create trigger trg_user_place_submissions_sync_queue
after insert or update on public.user_place_submissions
for each row execute function public.sync_moderation_queue_from_submission('place_submission');

drop trigger if exists trg_user_story_submissions_sync_queue on public.user_story_submissions;
create trigger trg_user_story_submissions_sync_queue
after insert or update on public.user_story_submissions
for each row execute function public.sync_moderation_queue_from_submission('story_submission');

drop trigger if exists trg_user_photo_submissions_sync_queue on public.user_photo_submissions;
create trigger trg_user_photo_submissions_sync_queue
after insert or update on public.user_photo_submissions
for each row execute function public.sync_moderation_queue_from_submission('photo_submission');

update public.user_place_submissions set updated_at = updated_at;
update public.user_story_submissions set updated_at = updated_at;
update public.user_photo_submissions set updated_at = updated_at;

create or replace function public.mirror_legacy_place_suggestion()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_city_id uuid;
begin
  select c.id into v_city_id
  from public.cities c
  where c.legacy_province_id = new.province_id;

  insert into public.user_place_submissions (
    legacy_place_suggestion_id,
    user_id,
    city_id,
    legacy_province_id,
    legacy_district_id,
    place_name,
    category_key,
    tag_slugs,
    short_note,
    source_url,
    lat,
    lng,
    status,
    admin_note,
    reviewed_by,
    submitted_at,
    reviewed_at,
    created_at,
    updated_at
  )
  values (
    new.id,
    new.user_id,
    v_city_id,
    new.province_id,
    new.district_id,
    new.suggested_name,
    new.suggested_category::text,
    coalesce(new.suggested_tags, '{}'::text[]),
    new.short_note,
    new.source_url,
    new.lat,
    new.lng,
    public.map_legacy_status(new.status),
    new.admin_note,
    new.reviewed_by,
    coalesce(new.created_at, now()),
    new.reviewed_at,
    coalesce(new.created_at, now()),
    coalesce(new.updated_at, now())
  )
  on conflict (legacy_place_suggestion_id) do update
  set
    user_id = excluded.user_id,
    city_id = excluded.city_id,
    legacy_province_id = excluded.legacy_province_id,
    legacy_district_id = excluded.legacy_district_id,
    place_name = excluded.place_name,
    category_key = excluded.category_key,
    tag_slugs = excluded.tag_slugs,
    short_note = excluded.short_note,
    source_url = excluded.source_url,
    lat = excluded.lat,
    lng = excluded.lng,
    status = excluded.status,
    admin_note = excluded.admin_note,
    reviewed_by = excluded.reviewed_by,
    submitted_at = excluded.submitted_at,
    reviewed_at = excluded.reviewed_at,
    updated_at = now();

  return new;
end;
$$;

create or replace function public.mirror_legacy_place_story_submission()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_new_submission_id uuid;
begin
  insert into public.user_story_submissions (
    legacy_place_story_submission_id,
    user_id,
    place_id,
    title,
    story_text,
    story_kind,
    status,
    admin_note,
    reviewed_by,
    submitted_at,
    reviewed_at,
    created_at,
    updated_at
  )
  values (
    new.id,
    new.user_id,
    new.place_id,
    new.title,
    new.story_text,
    new.fact_type::public.story_kind,
    public.map_legacy_status(new.status),
    new.admin_note,
    new.reviewed_by,
    coalesce(new.created_at, now()),
    new.reviewed_at,
    coalesce(new.created_at, now()),
    coalesce(new.updated_at, now())
  )
  on conflict (legacy_place_story_submission_id) do update
  set
    user_id = excluded.user_id,
    place_id = excluded.place_id,
    title = excluded.title,
    story_text = excluded.story_text,
    story_kind = excluded.story_kind,
    status = excluded.status,
    admin_note = excluded.admin_note,
    reviewed_by = excluded.reviewed_by,
    submitted_at = excluded.submitted_at,
    reviewed_at = excluded.reviewed_at,
    updated_at = now()
  returning id into v_new_submission_id;

  if public.map_legacy_status(new.status) = 'approved'::public.moderation_status then
    insert into public.place_stories (
      place_id,
      source_submission_id,
      author_user_id,
      title,
      story_kind,
      story_text,
      admin_note,
      is_published,
      published_at,
      created_at,
      updated_at
    )
    values (
      new.place_id,
      v_new_submission_id,
      new.user_id,
      new.title,
      new.fact_type::public.story_kind,
      new.story_text,
      new.admin_note,
      true,
      coalesce(new.reviewed_at, now()),
      coalesce(new.created_at, now()),
      now()
    )
    on conflict (source_submission_id) do update
    set
      title = excluded.title,
      story_kind = excluded.story_kind,
      story_text = excluded.story_text,
      admin_note = excluded.admin_note,
      is_published = true,
      unpublished_at = null,
      published_at = coalesce(public.place_stories.published_at, excluded.published_at),
      updated_at = now();
  end if;

  return new;
end;
$$;

create or replace function public.mirror_legacy_place_photo()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_new_submission_id uuid;
  v_image_kind public.place_image_kind := 'community';
begin
  insert into public.user_photo_submissions (
    legacy_place_photo_id,
    user_id,
    place_id,
    bucket,
    object_path,
    width,
    height,
    file_size_bytes,
    status,
    admin_note,
    submitted_at,
    created_at,
    updated_at
  )
  values (
    new.id,
    new.user_id,
    new.place_id,
    'place-photos',
    new.storage_path,
    new.width_px,
    new.height_px,
    new.file_size_bytes,
    public.map_legacy_status(new.status),
    new.moderation_note,
    coalesce(new.created_at, now()),
    coalesce(new.created_at, now()),
    coalesce(new.updated_at, now())
  )
  on conflict (legacy_place_photo_id) do update
  set
    user_id = excluded.user_id,
    place_id = excluded.place_id,
    object_path = excluded.object_path,
    width = excluded.width,
    height = excluded.height,
    file_size_bytes = excluded.file_size_bytes,
    status = excluded.status,
    admin_note = excluded.admin_note,
    updated_at = now()
  returning id into v_new_submission_id;

  if public.map_legacy_status(new.status) = 'approved'::public.moderation_status then
    insert into public.place_images (
      place_id,
      source_submission_id,
      bucket,
      object_path,
      image_type,
      width,
      height,
      file_size_bytes,
      is_active,
      is_published,
      created_by,
      published_at,
      created_at,
      updated_at
    )
    values (
      new.place_id,
      v_new_submission_id,
      'place-photos',
      new.storage_path,
      v_image_kind,
      new.width_px,
      new.height_px,
      new.file_size_bytes,
      true,
      true,
      new.user_id,
      now(),
      coalesce(new.created_at, now()),
      now()
    )
    on conflict (place_id, bucket, object_path) do update
    set
      is_active = true,
      is_published = true,
      deleted_at = null,
      updated_at = now();
  end if;

  return new;
end;
$$;

drop trigger if exists trg_place_suggestions_mirror_unified on public.place_suggestions;
create trigger trg_place_suggestions_mirror_unified
after insert or update on public.place_suggestions
for each row execute function public.mirror_legacy_place_suggestion();

drop trigger if exists trg_place_story_submissions_mirror_unified on public.place_story_submissions;
create trigger trg_place_story_submissions_mirror_unified
after insert or update on public.place_story_submissions
for each row execute function public.mirror_legacy_place_story_submission();

drop trigger if exists trg_place_photos_mirror_unified on public.place_photos;
create trigger trg_place_photos_mirror_unified
after insert or update on public.place_photos
for each row execute function public.mirror_legacy_place_photo();

insert into public.place_stories (
  place_id,
  source_submission_id,
  author_user_id,
  title,
  story_kind,
  story_text,
  admin_note,
  is_published,
  published_at,
  created_at,
  updated_at
)
select
  uss.place_id,
  uss.id,
  uss.user_id,
  uss.title,
  uss.story_kind,
  uss.story_text,
  uss.admin_note,
  true,
  coalesce(uss.reviewed_at, uss.created_at, now()),
  uss.created_at,
  now()
from public.user_story_submissions uss
where uss.status = 'approved'
on conflict (source_submission_id) do nothing;

update public.user_story_submissions uss
set approved_story_id = ps.id
from public.place_stories ps
where ps.source_submission_id = uss.id
  and uss.approved_story_id is null;

insert into public.place_images (
  place_id,
  source_submission_id,
  bucket,
  object_path,
  image_type,
  width,
  height,
  file_size_bytes,
  is_active,
  is_published,
  created_by,
  published_at,
  created_at,
  updated_at
)
select
  ups.place_id,
  ups.id,
  ups.bucket,
  ups.object_path,
  'community'::public.place_image_kind,
  ups.width,
  ups.height,
  ups.file_size_bytes,
  true,
  true,
  ups.user_id,
  coalesce(ups.reviewed_at, ups.created_at, now()),
  ups.created_at,
  now()
from public.user_photo_submissions ups
where ups.status = 'approved'
on conflict (place_id, bucket, object_path) do nothing;

update public.user_photo_submissions ups
set approved_place_image_id = pi.id
from public.place_images pi
where pi.source_submission_id = ups.id
  and ups.approved_place_image_id is null;

create or replace function public.write_admin_audit_log(
  p_action text,
  p_target_table text,
  p_target_id uuid,
  p_queue_id uuid default null,
  p_old_data jsonb default null,
  p_new_data jsonb default null,
  p_metadata jsonb default '{}'::jsonb
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.admin_audit_logs (
    admin_user_id,
    action,
    target_table,
    target_id,
    moderation_queue_id,
    old_data,
    new_data,
    metadata
  )
  values (
    auth.uid(),
    p_action,
    p_target_table,
    p_target_id,
    p_queue_id,
    p_old_data,
    p_new_data,
    coalesce(p_metadata, '{}'::jsonb)
  );
end;
$$;

create or replace function public.ensure_tag_records(p_tag_slugs text[])
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_tag text;
begin
  foreach v_tag in array coalesce(p_tag_slugs, '{}'::text[]) loop
    if nullif(trim(v_tag), '') is null then
      continue;
    end if;

    insert into public.tags (slug, label)
    values (
      lower(trim(v_tag))::citext,
      initcap(replace(lower(trim(v_tag)), '_', ' '))
    )
    on conflict (slug) do nothing;
  end loop;
end;
$$;

create or replace function public.publish_story_submission(
  p_submission_id uuid,
  p_admin_note text default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_submission public.user_story_submissions%rowtype;
  v_story_id uuid;
begin
  select *
  into v_submission
  from public.user_story_submissions
  where id = p_submission_id
  for update;

  if not found then
    raise exception 'story_submission_not_found';
  end if;

  insert into public.place_stories (
    place_id,
    source_submission_id,
    author_user_id,
    title,
    story_kind,
    story_text,
    admin_note,
    is_published,
    published_at,
    created_at,
    updated_at
  )
  values (
    v_submission.place_id,
    v_submission.id,
    v_submission.user_id,
    v_submission.title,
    v_submission.story_kind,
    v_submission.story_text,
    coalesce(nullif(trim(coalesce(p_admin_note, '')), ''), v_submission.admin_note),
    true,
    now(),
    v_submission.created_at,
    now()
  )
  on conflict (source_submission_id) do update
  set
    title = excluded.title,
    story_kind = excluded.story_kind,
    story_text = excluded.story_text,
    admin_note = excluded.admin_note,
    is_published = true,
    unpublished_at = null,
    published_at = coalesce(public.place_stories.published_at, now()),
    updated_at = now()
  returning id into v_story_id;

  update public.user_story_submissions
  set
    status = 'approved',
    admin_note = coalesce(nullif(trim(coalesce(p_admin_note, '')), ''), admin_note),
    rejection_reason = null,
    approved_story_id = v_story_id,
    reviewed_at = now(),
    reviewed_by = auth.uid(),
    updated_at = now()
  where id = p_submission_id;

  return v_story_id;
end;
$$;

create or replace function public.publish_photo_submission(
  p_submission_id uuid,
  p_admin_note text default null,
  p_set_cover boolean default false
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_submission public.user_photo_submissions%rowtype;
  v_image_id uuid;
  v_image_type public.place_image_kind := case when p_set_cover then 'cover'::public.place_image_kind else 'community'::public.place_image_kind end;
begin
  select *
  into v_submission
  from public.user_photo_submissions
  where id = p_submission_id
  for update;

  if not found then
    raise exception 'photo_submission_not_found';
  end if;

  insert into public.place_images (
    place_id,
    source_submission_id,
    bucket,
    object_path,
    image_type,
    mime_type,
    width,
    height,
    file_size_bytes,
    alt_text,
    is_active,
    is_published,
    created_by,
    published_at,
    created_at,
    updated_at
  )
  values (
    v_submission.place_id,
    v_submission.id,
    v_submission.bucket,
    v_submission.object_path,
    v_image_type,
    v_submission.mime_type,
    v_submission.width,
    v_submission.height,
    v_submission.file_size_bytes,
    v_submission.caption,
    true,
    true,
    v_submission.user_id,
    now(),
    v_submission.created_at,
    now()
  )
  on conflict (place_id, bucket, object_path) do update
  set
    image_type = excluded.image_type,
    mime_type = excluded.mime_type,
    width = excluded.width,
    height = excluded.height,
    file_size_bytes = excluded.file_size_bytes,
    alt_text = excluded.alt_text,
    is_active = true,
    is_published = true,
    deleted_at = null,
    updated_at = now()
  returning id into v_image_id;

  update public.user_photo_submissions
  set
    status = 'approved',
    admin_note = coalesce(nullif(trim(coalesce(p_admin_note, '')), ''), admin_note),
    rejection_reason = null,
    approved_place_image_id = v_image_id,
    reviewed_at = now(),
    reviewed_by = auth.uid(),
    updated_at = now()
  where id = p_submission_id;

  return v_image_id;
end;
$$;

create or replace function public.approve_place_submission(
  p_submission_id uuid,
  p_publish_cover boolean default true
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_submission public.user_place_submissions%rowtype;
  v_place_id uuid;
  v_city_name text;
  v_district_name text;
begin
  select *
  into v_submission
  from public.user_place_submissions
  where id = p_submission_id
  for update;

  if not found then
    raise exception 'place_submission_not_found';
  end if;

  if v_submission.approved_place_id is not null then
    v_place_id := v_submission.approved_place_id;
  else
    select p.name into v_city_name
    from public.provinces p
    where p.id = v_submission.legacy_province_id;

    select d.name into v_district_name
    from public.districts d
    where d.id = v_submission.legacy_district_id;

    insert into public.pois (
      id,
      name,
      category,
      lat,
      lng,
      city,
      district,
      tags,
      source,
      provenance_verified,
      provenance_checked_at,
      updated_at
    )
    values (
      gen_random_uuid(),
      v_submission.place_name,
      v_submission.category_key,
      v_submission.lat,
      v_submission.lng,
      v_city_name,
      v_district_name,
      to_jsonb(coalesce(v_submission.tag_slugs, '{}'::text[])),
      'user',
      false,
      null,
      now()
    )
    returning id into v_place_id;
  end if;

  perform public.ensure_tag_records(v_submission.tag_slugs);

  insert into public.place_tag_map (place_id, tag_id)
  select
    v_place_id,
    t.id
  from public.tags t
  where t.slug = any (coalesce(v_submission.tag_slugs, '{}'::text[])::citext[])
  on conflict do nothing;

  if p_publish_cover is true
     and nullif(trim(coalesce(v_submission.cover_bucket, '')), '') is not null
     and nullif(trim(coalesce(v_submission.cover_object_path, '')), '') is not null then
    insert into public.place_images (
      place_id,
      source_submission_id,
      bucket,
      object_path,
      image_type,
      is_active,
      is_published,
      created_by,
      published_at,
      created_at,
      updated_at
    )
    values (
      v_place_id,
      v_submission.id,
      v_submission.cover_bucket,
      v_submission.cover_object_path,
      'cover',
      true,
      true,
      v_submission.user_id,
      now(),
      v_submission.created_at,
      now()
    )
    on conflict (place_id, bucket, object_path) do nothing;
  end if;

  update public.user_place_submissions
  set
    status = 'approved',
    admin_note = null,
    rejection_reason = null,
    approved_place_id = v_place_id,
    reviewed_at = now(),
    reviewed_by = auth.uid(),
    updated_at = now()
  where id = p_submission_id;

  return v_place_id;
end;
$$;

create or replace function public.admin_moderate_submission(
  p_submission_type public.moderation_submission_type,
  p_submission_id uuid,
  p_decision public.moderation_status,
  p_admin_note text default null,
  p_rejection_reason text default null,
  p_publish boolean default true,
  p_set_cover boolean default false
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_queue_before public.moderation_queue%rowtype;
  v_result_id uuid;
begin
  if auth.uid() is null or not public.is_admin(auth.uid()) then
    raise exception 'admin_required';
  end if;

  select *
  into v_queue_before
  from public.moderation_queue
  where submission_type = p_submission_type
    and submission_id = p_submission_id
  for update;

  if not found then
    raise exception 'moderation_queue_row_not_found';
  end if;

  if p_submission_type = 'story_submission' then
    if p_decision = 'approved' and p_publish then
      v_result_id := public.publish_story_submission(p_submission_id, p_admin_note);
    else
      update public.user_story_submissions
      set
        status = p_decision,
        admin_note = nullif(trim(coalesce(p_admin_note, '')), ''),
        rejection_reason = nullif(trim(coalesce(p_rejection_reason, '')), ''),
        reviewed_at = now(),
        reviewed_by = auth.uid(),
        updated_at = now()
      where id = p_submission_id;
    end if;
  elsif p_submission_type = 'photo_submission' then
    if p_decision = 'approved' and p_publish then
      v_result_id := public.publish_photo_submission(p_submission_id, p_admin_note, p_set_cover);
    else
      update public.user_photo_submissions
      set
        status = p_decision,
        admin_note = nullif(trim(coalesce(p_admin_note, '')), ''),
        rejection_reason = nullif(trim(coalesce(p_rejection_reason, '')), ''),
        reviewed_at = now(),
        reviewed_by = auth.uid(),
        updated_at = now()
      where id = p_submission_id;
    end if;
  elsif p_submission_type = 'place_submission' then
    if p_decision = 'approved' and p_publish then
      v_result_id := public.approve_place_submission(p_submission_id);
    else
      update public.user_place_submissions
      set
        status = p_decision,
        admin_note = nullif(trim(coalesce(p_admin_note, '')), ''),
        rejection_reason = nullif(trim(coalesce(p_rejection_reason, '')), ''),
        reviewed_at = now(),
        reviewed_by = auth.uid(),
        updated_at = now()
      where id = p_submission_id;
    end if;
  else
    raise exception 'unsupported_submission_type';
  end if;

  update public.moderation_queue
  set
    status = p_decision,
    admin_note = nullif(trim(coalesce(p_admin_note, '')), ''),
    rejection_reason = nullif(trim(coalesce(p_rejection_reason, '')), ''),
    reviewed_at = now(),
    reviewed_by = auth.uid(),
    updated_at = now()
  where submission_type = p_submission_type
    and submission_id = p_submission_id;

  perform public.write_admin_audit_log(
    'moderate_submission',
    p_submission_type::text,
    p_submission_id,
    v_queue_before.id,
    to_jsonb(v_queue_before),
    (
      select to_jsonb(mq)
      from public.moderation_queue mq
      where mq.id = v_queue_before.id
    ),
    jsonb_build_object(
      'decision', p_decision,
      'publish', p_publish,
      'set_cover', p_set_cover,
      'result_id', v_result_id
    )
  );

  return jsonb_build_object(
    'submission_type', p_submission_type,
    'submission_id', p_submission_id,
    'decision', p_decision,
    'result_id', v_result_id
  );
end;
$$;

create or replace function public.admin_unpublish_story(p_story_id uuid, p_admin_note text default null)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null or not public.is_admin(auth.uid()) then
    raise exception 'admin_required';
  end if;

  update public.place_stories
  set
    is_published = false,
    unpublished_at = now(),
    admin_note = nullif(trim(coalesce(p_admin_note, '')), ''),
    updated_at = now()
  where id = p_story_id;

  perform public.write_admin_audit_log(
    'unpublish_story',
    'place_stories',
    p_story_id,
    null,
    null,
    (
      select to_jsonb(ps)
      from public.place_stories ps
      where ps.id = p_story_id
    ),
    jsonb_build_object('admin_note', p_admin_note)
  );
end;
$$;

alter table public.cities enable row level security;
alter table public.categories enable row level security;
alter table public.tags enable row level security;
alter table public.place_images enable row level security;
alter table public.place_stories enable row level security;
alter table public.place_tag_map enable row level security;
alter table public.featured_places enable row level security;
alter table public.weekly_routes enable row level security;
alter table public.user_place_submissions enable row level security;
alter table public.user_story_submissions enable row level security;
alter table public.user_photo_submissions enable row level security;
alter table public.moderation_queue enable row level security;
alter table public.admin_audit_logs enable row level security;

drop policy if exists cities_public_read on public.cities;
create policy cities_public_read
on public.cities
for select
using (is_active = true);

drop policy if exists categories_public_read on public.categories;
create policy categories_public_read
on public.categories
for select
using (is_active = true);

drop policy if exists tags_public_read on public.tags;
create policy tags_public_read
on public.tags
for select
using (is_active = true);

drop policy if exists place_images_public_read on public.place_images;
create policy place_images_public_read
on public.place_images
for select
using (is_published = true and is_active = true and deleted_at is null);

drop policy if exists place_stories_public_read on public.place_stories;
create policy place_stories_public_read
on public.place_stories
for select
using (is_published = true and deleted_at is null);

drop policy if exists place_tag_map_public_read on public.place_tag_map;
create policy place_tag_map_public_read
on public.place_tag_map
for select
using (true);

drop policy if exists featured_places_public_read on public.featured_places;
create policy featured_places_public_read
on public.featured_places
for select
using (
  is_active = true
  and (starts_at is null or starts_at <= now())
  and (ends_at is null or ends_at >= now())
);

drop policy if exists weekly_routes_public_read on public.weekly_routes;
create policy weekly_routes_public_read
on public.weekly_routes
for select
using (
  is_published = true
  and deleted_at is null
  and (starts_at is null or starts_at <= now())
  and (ends_at is null or ends_at >= now())
);

drop policy if exists user_place_submissions_select_owner_or_admin on public.user_place_submissions;
create policy user_place_submissions_select_owner_or_admin
on public.user_place_submissions
for select
to authenticated
using (auth.uid() = user_id or public.is_admin(auth.uid()));

drop policy if exists user_place_submissions_insert_owner on public.user_place_submissions;
create policy user_place_submissions_insert_owner
on public.user_place_submissions
for insert
to authenticated
with check (
  auth.uid() = user_id
  and status = 'pending'
);

drop policy if exists user_place_submissions_update_owner_or_admin on public.user_place_submissions;
create policy user_place_submissions_update_owner_or_admin
on public.user_place_submissions
for update
to authenticated
using (
  public.is_admin(auth.uid())
  or (
    auth.uid() = user_id
    and status in ('pending', 'needs_edit')
  )
)
with check (
  public.is_admin(auth.uid())
  or (
    auth.uid() = user_id
    and user_id = auth.uid()
    and status in ('pending', 'needs_edit')
  )
);

drop policy if exists user_story_submissions_select_owner_or_admin on public.user_story_submissions;
create policy user_story_submissions_select_owner_or_admin
on public.user_story_submissions
for select
to authenticated
using (auth.uid() = user_id or public.is_admin(auth.uid()));

drop policy if exists user_story_submissions_insert_owner on public.user_story_submissions;
create policy user_story_submissions_insert_owner
on public.user_story_submissions
for insert
to authenticated
with check (
  auth.uid() = user_id
  and status = 'pending'
);

drop policy if exists user_story_submissions_update_owner_or_admin on public.user_story_submissions;
create policy user_story_submissions_update_owner_or_admin
on public.user_story_submissions
for update
to authenticated
using (
  public.is_admin(auth.uid())
  or (
    auth.uid() = user_id
    and status in ('pending', 'needs_edit')
  )
)
with check (
  public.is_admin(auth.uid())
  or (
    auth.uid() = user_id
    and user_id = auth.uid()
    and status in ('pending', 'needs_edit')
  )
);

drop policy if exists user_photo_submissions_select_owner_or_admin on public.user_photo_submissions;
create policy user_photo_submissions_select_owner_or_admin
on public.user_photo_submissions
for select
to authenticated
using (auth.uid() = user_id or public.is_admin(auth.uid()));

drop policy if exists user_photo_submissions_insert_owner on public.user_photo_submissions;
create policy user_photo_submissions_insert_owner
on public.user_photo_submissions
for insert
to authenticated
with check (
  auth.uid() = user_id
  and status = 'pending'
);

drop policy if exists user_photo_submissions_update_owner_or_admin on public.user_photo_submissions;
create policy user_photo_submissions_update_owner_or_admin
on public.user_photo_submissions
for update
to authenticated
using (
  public.is_admin(auth.uid())
  or (
    auth.uid() = user_id
    and status in ('pending', 'needs_edit')
  )
)
with check (
  public.is_admin(auth.uid())
  or (
    auth.uid() = user_id
    and user_id = auth.uid()
    and status in ('pending', 'needs_edit')
  )
);

drop policy if exists moderation_queue_admin_only on public.moderation_queue;
create policy moderation_queue_admin_only
on public.moderation_queue
for all
to authenticated
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

drop policy if exists admin_audit_logs_admin_only on public.admin_audit_logs;
create policy admin_audit_logs_admin_only
on public.admin_audit_logs
for all
to authenticated
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

drop policy if exists place_images_admin_all on public.place_images;
create policy place_images_admin_all
on public.place_images
for all
to authenticated
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

drop policy if exists place_stories_admin_all on public.place_stories;
create policy place_stories_admin_all
on public.place_stories
for all
to authenticated
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

drop policy if exists place_tag_map_admin_all on public.place_tag_map;
create policy place_tag_map_admin_all
on public.place_tag_map
for all
to authenticated
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

drop policy if exists featured_places_admin_all on public.featured_places;
create policy featured_places_admin_all
on public.featured_places
for all
to authenticated
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

drop policy if exists weekly_routes_admin_all on public.weekly_routes;
create policy weekly_routes_admin_all
on public.weekly_routes
for all
to authenticated
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

drop policy if exists cities_admin_all on public.cities;
create policy cities_admin_all
on public.cities
for all
to authenticated
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

drop policy if exists categories_admin_all on public.categories;
create policy categories_admin_all
on public.categories
for all
to authenticated
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

drop policy if exists tags_admin_all on public.tags;
create policy tags_admin_all
on public.tags
for all
to authenticated
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

insert into storage.buckets (id, name, public)
values
  ('place-covers', 'place-covers', true),
  ('place-gallery', 'place-gallery', true),
  ('community-photos', 'community-photos', false),
  ('story-assets', 'story-assets', false),
  ('temp-uploads', 'temp-uploads', false)
on conflict (id) do update
set public = excluded.public;

drop policy if exists "Public read place-covers" on storage.objects;
create policy "Public read place-covers"
on storage.objects
for select
using (bucket_id = 'place-covers');

drop policy if exists "Public read place-gallery" on storage.objects;
create policy "Public read place-gallery"
on storage.objects
for select
using (bucket_id = 'place-gallery');

drop policy if exists "Authenticated upload community-photos" on storage.objects;
create policy "Authenticated upload community-photos"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'community-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Authenticated read own community-photos or admin" on storage.objects;
create policy "Authenticated read own community-photos or admin"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'community-photos'
  and (
    (storage.foldername(name))[1] = auth.uid()::text
    or public.is_admin(auth.uid())
  )
);

drop policy if exists "Authenticated upload story-assets" on storage.objects;
create policy "Authenticated upload story-assets"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'story-assets'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Authenticated read own story-assets or admin" on storage.objects;
create policy "Authenticated read own story-assets or admin"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'story-assets'
  and (
    (storage.foldername(name))[1] = auth.uid()::text
    or public.is_admin(auth.uid())
  )
);

drop policy if exists "Authenticated temp-uploads own access" on storage.objects;
create policy "Authenticated temp-uploads own access"
on storage.objects
for all
to authenticated
using (
  bucket_id = 'temp-uploads'
  and (
    (storage.foldername(name))[1] = auth.uid()::text
    or public.is_admin(auth.uid())
  )
)
with check (
  bucket_id = 'temp-uploads'
  and (
    (storage.foldername(name))[1] = auth.uid()::text
    or public.is_admin(auth.uid())
  )
);

create or replace view public.moderation_queue_overview
with (security_invoker = on)
as
select
  mq.id,
  mq.submission_type,
  mq.submission_id,
  mq.status,
  mq.user_id,
  mq.place_id,
  mq.city_id,
  mq.searchable_title,
  mq.searchable_excerpt,
  mq.bucket,
  mq.object_path,
  mq.admin_note,
  mq.rejection_reason,
  mq.queue_rank,
  mq.submitted_at,
  mq.reviewed_at,
  mq.reviewed_by,
  p.name as place_name,
  c.name as city_name,
  pr.display_name as submitter_name
from public.moderation_queue mq
left join public.pois p on p.id = mq.place_id
left join public.cities c on c.id = mq.city_id
left join public.profiles pr on pr.id = mq.user_id;

grant select on public.moderation_queue_overview to authenticated;

commit;
