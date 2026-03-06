create or replace view public.places_with_coords
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
  st_y(p.geog::geometry) as lat,
  st_x(p.geog::geometry) as lng
from public.places p;

grant select on public.places_with_coords to anon, authenticated;

create or replace function public.get_place_distance_meters(
  from_lat double precision,
  from_lng double precision,
  to_place_id uuid
)
returns double precision
language sql
stable
security invoker
as $$
  select st_distance(
    st_setsrid(st_makepoint(from_lng, from_lat), 4326)::geography,
    p.geog
  )
  from public.places p
  where p.id = to_place_id;
$$;

grant execute on function public.get_place_distance_meters(double precision, double precision, uuid) to anon, authenticated;
