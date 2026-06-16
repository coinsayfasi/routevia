-- Add geography column to pois for efficient spatial queries.
-- Uses ST_DWithin instead of client-side bounding box + Dart filtering.

-- 1. Add geog column (populated from lat/lng)
alter table public.pois
  add column if not exists geog geography(point, 4326)
  generated always as (
    case
      when lat is not null and lng is not null
      then st_setsrid(st_makepoint(lng, lat), 4326)::geography
      else null
    end
  ) stored;

-- 2. Spatial index for ST_DWithin queries
create index if not exists pois_geog_idx
  on public.pois using gist (geog);

-- 3. Composite indexes for province/district filters
create index if not exists pois_city_verified_idx
  on public.pois (city, provenance_verified)
  where provenance_verified = true;

create index if not exists pois_district_verified_idx
  on public.pois (district, provenance_verified)
  where provenance_verified = true;

-- 4. RPC: pois_by_viewport — replaces client-side .limit(1000) fetch
-- Returns up to p_limit POIs inside the bounding box, ordered by distance to center.
create or replace function public.pois_by_viewport(
  p_min_lat  double precision,
  p_max_lat  double precision,
  p_min_lng  double precision,
  p_max_lng  double precision,
  p_center_lat double precision default null,
  p_center_lng double precision default null,
  p_city     text default null,
  p_district text default null,
  p_categories text[] default null,
  p_limit    int default 200
)
returns table (
  id                  text,
  name                text,
  category            text,
  lat                 double precision,
  lng                 double precision,
  city                text,
  district            text,
  tags                jsonb,
  source              text,
  distance_km         double precision
)
language sql
stable
security invoker
set search_path = public
as $$
  with center as (
    select
      case
        when p_center_lat is not null and p_center_lng is not null
        then st_setsrid(st_makepoint(p_center_lng, p_center_lat), 4326)::geography
        else st_setsrid(st_makepoint(
          (p_min_lng + p_max_lng) / 2.0,
          (p_min_lat + p_max_lat) / 2.0
        ), 4326)::geography
      end as g
  )
  select
    p.id::text,
    p.name,
    p.category,
    p.lat::double precision,
    p.lng::double precision,
    p.city,
    p.district,
    p.tags,
    p.source,
    round((st_distance(p.geog, c.g) / 1000.0)::numeric, 2)::double precision as distance_km
  from public.pois p, center c
  where
    p.provenance_verified = true
    and p.lat between p_min_lat and p_max_lat
    and p.lng between p_min_lng and p_max_lng
    and (p_city     is null or p.city     ilike p_city)
    and (p_district is null or p.district ilike p_district)
    and (p_categories is null or array_length(p_categories, 1) = 0
         or p.category = any(p_categories))
  order by st_distance(p.geog, c.g)
  limit p_limit;
$$;

grant execute on function public.pois_by_viewport to anon, authenticated;
