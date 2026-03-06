-- Backfill compliant map dataset from clean owned dataset
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
  created_at,
  updated_at
)
select
  p.id,
  p.name,
  p.category::text,
  st_y(p.geog::geometry) as lat,
  st_x(p.geog::geometry) as lng,
  pr.name as city,
  d.name as district,
  to_jsonb(coalesce(p.tags, '{}'::text[])) as tags,
  'osm'::text as source,
  now(),
  now()
from public.places_clean p
join public.provinces pr on pr.id = p.province_id
left join public.districts d on d.id = p.district_id
where p.name is not null
  and length(trim(p.name)) > 0
on conflict (id) do update
set
  name = excluded.name,
  category = excluded.category,
  lat = excluded.lat,
  lng = excluded.lng,
  city = excluded.city,
  district = excluded.district,
  tags = excluded.tags,
  source = excluded.source,
  updated_at = now();
