create or replace view public.districts_with_coords
with (security_invoker = on)
as
select
  d.id,
  d.province_id,
  d.name,
  d.slug,
  st_y(d.center_geog::geometry) as lat,
  st_x(d.center_geog::geometry) as lng
from public.districts d;

grant select on public.districts_with_coords to anon, authenticated;
