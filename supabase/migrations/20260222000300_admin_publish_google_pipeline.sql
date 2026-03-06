-- Admin publish workflow + Google metadata + rating blend

alter table public.places
  add column if not exists is_published boolean not null default true,
  add column if not exists published_at timestamptz,
  add column if not exists google_rating numeric(3,2),
  add column if not exists google_review_count int,
  add column if not exists google_source_url text,
  add column if not exists google_updated_at timestamptz;

alter table public.places
  drop constraint if exists places_google_review_count_check;
alter table public.places
  add constraint places_google_review_count_check check (google_review_count is null or google_review_count >= 0);

create index if not exists places_is_published_idx on public.places(is_published);

update public.places
set published_at = coalesce(published_at, now())
where is_published = true;

-- Public can only read published content.
drop policy if exists "public_read_places" on public.places;
create policy "public_read_places"
on public.places
for select
to anon, authenticated
using (is_published = true);

drop policy if exists "public_read_place_details" on public.place_details;
create policy "public_read_place_details"
on public.place_details
for select
to anon, authenticated
using (
  exists (
    select 1
    from public.places p
    where p.id = place_details.place_id
      and p.is_published = true
  )
);

drop policy if exists "public_read_place_media" on public.place_media;
create policy "public_read_place_media"
on public.place_media
for select
to anon, authenticated
using (
  exists (
    select 1
    from public.places p
    where p.id = place_media.place_id
      and p.is_published = true
  )
);

-- Admin write policies on content tables.
drop policy if exists "places_admin_all" on public.places;
create policy "places_admin_all"
on public.places
for all
to authenticated
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

drop policy if exists "place_details_admin_all" on public.place_details;
create policy "place_details_admin_all"
on public.place_details
for all
to authenticated
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

drop policy if exists "place_media_admin_all" on public.place_media;
create policy "place_media_admin_all"
on public.place_media
for all
to authenticated
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

-- Include publish/google fields in coordinate view
drop view if exists public.places_with_coords;
create view public.places_with_coords
with (security_invoker = on)
as
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
  p.price_level,
  p.is_published,
  p.google_rating,
  p.google_review_count,
  p.google_source_url,
  p.google_updated_at,
  st_y(p.geog::geometry) as lat,
  st_x(p.geog::geometry) as lng
from public.places p;

grant select on public.places_with_coords to anon, authenticated;

drop view if exists public.admin_places_overview;
create view public.admin_places_overview
with (security_invoker = on)
as
select
  p.id,
  p.name,
  p.slug,
  p.category,
  p.short_summary,
  p.best_time,
  p.duration_min,
  p.tags,
  p.popularity_score,
  p.is_free,
  p.price_level,
  p.is_published,
  p.google_place_id,
  p.google_rating,
  p.google_review_count,
  p.google_source_url,
  p.google_updated_at,
  p.created_at,
  p.updated_at,
  p.published_at,
  st_y(p.geog::geometry) as lat,
  st_x(p.geog::geometry) as lng,
  pr.id as province_id,
  pr.name as province_name,
  pr.slug as province_slug,
  d.id as district_id,
  d.name as district_name,
  d.slug as district_slug
from public.places p
join public.provinces pr on pr.id = p.province_id
left join public.districts d on d.id = p.district_id;

-- Keep view admin-only via base table RLS
revoke all on public.admin_places_overview from anon, authenticated;
grant select on public.admin_places_overview to authenticated;

-- Blend community + google ratings for map badges.
create or replace view public.place_stats
with (security_invoker = on)
as
with community as (
  select
    r.place_id,
    round(avg(r.rating)::numeric, 2) as avg_rating,
    count(*)::int as review_count,
    round(avg(case when r.flags && array['crowded']::text[] then 1 else 0 end)::numeric, 3) as crowded_score,
    round(avg(case when r.flags && array['family']::text[] then 1 else 0 end)::numeric, 3) as family_score,
    round(avg(case when r.flags && array['photo_spot','sunset_worthy']::text[] then 1 else 0 end)::numeric, 3) as photo_score
  from public.place_reviews r
  group by r.place_id
)
select
  p.id as place_id,
  coalesce(c.avg_rating, p.google_rating, 0)::numeric as avg_rating,
  (coalesce(c.review_count, 0) + coalesce(p.google_review_count, 0))::int as review_count,
  coalesce(c.crowded_score, 0)::numeric as crowded_score,
  coalesce(c.family_score, 0)::numeric as family_score,
  coalesce(c.photo_score, 0)::numeric as photo_score
from public.places p
left join community c on c.place_id = p.id
where p.is_published = true;

grant select on public.place_stats to anon, authenticated;

-- Nearby RPC must never return unpublished places
create or replace function public.nearby_places_rpc(
  p_lat double precision,
  p_lng double precision,
  p_radius_m integer,
  p_province_id uuid default null,
  p_category text default null,
  p_tags text[] default null,
  p_is_free_only boolean default false,
  p_limit integer default 30
)
returns table (
  id uuid,
  name text,
  lat double precision,
  lng double precision,
  distance_m double precision,
  short_summary text,
  category public.place_category,
  tags text[],
  best_time public.best_time,
  duration_min int,
  is_free boolean,
  popularity_score int,
  rating numeric,
  review_count int,
  image_path text,
  image_sort_order int
)
language sql
stable
security invoker
as $$
  with origin as (
    select st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography as g
  )
  select
    p.id,
    p.name,
    st_y(p.geog::geometry) as lat,
    st_x(p.geog::geometry) as lng,
    st_distance(p.geog, o.g) as distance_m,
    p.short_summary,
    p.category,
    p.tags,
    p.best_time,
    p.duration_min,
    p.is_free,
    p.popularity_score,
    coalesce(ps.avg_rating, 0)::numeric as rating,
    coalesce(ps.review_count, 0)::int as review_count,
    pm.storage_path as image_path,
    pm.sort_order as image_sort_order
  from public.places p
  cross join origin o
  left join public.place_stats ps on ps.place_id = p.id
  left join lateral (
    select m.storage_path, m.sort_order
    from public.place_media m
    where m.place_id = p.id
    order by m.sort_order asc
    limit 1
  ) pm on true
  where p.is_published = true
    and st_dwithin(p.geog, o.g, p_radius_m)
    and (p_province_id is null or p.province_id = p_province_id)
    and (p_category is null or p.category::text = p_category)
    and (
      p_tags is null
      or coalesce(array_length(p_tags, 1), 0) = 0
      or p.tags && p_tags
    )
    and (not p_is_free_only or p.is_free = true)
  order by st_distance(p.geog, o.g) asc, p.popularity_score desc
  limit greatest(1, least(p_limit, 30));
$$;

grant execute on function public.nearby_places_rpc(double precision, double precision, integer, uuid, text, text[], boolean, integer) to anon, authenticated;

create or replace function public.nearest_places_in_province_rpc(
  p_lat double precision,
  p_lng double precision,
  p_province_id uuid,
  p_category text default null,
  p_tags text[] default null,
  p_is_free_only boolean default false,
  p_limit integer default 30
)
returns table (
  id uuid,
  name text,
  lat double precision,
  lng double precision,
  distance_m double precision,
  short_summary text,
  category public.place_category,
  tags text[],
  best_time public.best_time,
  duration_min int,
  is_free boolean,
  popularity_score int,
  rating numeric,
  review_count int,
  image_path text,
  image_sort_order int
)
language sql
stable
security invoker
as $$
  with origin as (
    select st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography as g
  )
  select
    p.id,
    p.name,
    st_y(p.geog::geometry) as lat,
    st_x(p.geog::geometry) as lng,
    st_distance(p.geog, o.g) as distance_m,
    p.short_summary,
    p.category,
    p.tags,
    p.best_time,
    p.duration_min,
    p.is_free,
    p.popularity_score,
    coalesce(ps.avg_rating, 0)::numeric as rating,
    coalesce(ps.review_count, 0)::int as review_count,
    pm.storage_path as image_path,
    pm.sort_order as image_sort_order
  from public.places p
  cross join origin o
  left join public.place_stats ps on ps.place_id = p.id
  left join lateral (
    select m.storage_path, m.sort_order
    from public.place_media m
    where m.place_id = p.id
    order by m.sort_order asc
    limit 1
  ) pm on true
  where p.is_published = true
    and p.province_id = p_province_id
    and (p_category is null or p.category::text = p_category)
    and (
      p_tags is null
      or coalesce(array_length(p_tags, 1), 0) = 0
      or p.tags && p_tags
    )
    and (not p_is_free_only or p.is_free = true)
  order by st_distance(p.geog, o.g) asc, p.popularity_score desc
  limit greatest(1, least(p_limit, 30));
$$;

grant execute on function public.nearest_places_in_province_rpc(double precision, double precision, uuid, text, text[], boolean, integer) to anon, authenticated;
