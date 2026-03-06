create or replace view public.provinces_with_coords
with (security_invoker = on)
as
select
  p.id,
  p.name,
  p.slug,
  p.plate_no,
  st_y(p.center_geog::geometry) as lat,
  st_x(p.center_geog::geometry) as lng
from public.provinces p;

grant select on public.provinces_with_coords to anon, authenticated;
