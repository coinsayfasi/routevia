drop view if exists public.curated_district_mismatch_report;

create view public.curated_district_mismatch_report as
select
  p.id as place_id,
  p.name,
  p.slug,
  p.is_published,
  p.province_id,
  pr.name as province_name,
  p.district_id as assigned_district_id,
  d_assigned.name as assigned_district_name,
  d_near.id as nearest_district_id,
  d_near.name as nearest_district_name,
  st_distance(p.geog, d_assigned.center_geog) as assigned_distance_m,
  st_distance(p.geog, d_near.center_geog) as nearest_distance_m
from public.places p
join public.provinces pr on pr.id = p.province_id
left join public.districts d_assigned on d_assigned.id = p.district_id
left join lateral (
  select d2.id, d2.name, d2.center_geog
  from public.districts d2
  where d2.province_id = p.province_id
  order by d2.center_geog <-> p.geog
  limit 1
) d_near on true
where p.source_kind = 'curated'::public.source_kind
  and p.geog is not null;

grant select on public.curated_district_mismatch_report to authenticated;
