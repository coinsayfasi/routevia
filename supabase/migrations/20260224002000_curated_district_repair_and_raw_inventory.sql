-- Preserve raw archive visibility + curated district repair utilities.
-- This migration does NOT delete or overwrite raw archive rows.

-- 1) Inventory view for raw/legacy archive tables (google/raw related columns)
create or replace view public.raw_archive_tables_inventory as
select
  c.table_schema,
  c.table_name,
  count(*)::int as matched_columns,
  array_agg(c.column_name order by c.ordinal_position) as matched_column_names
from information_schema.columns c
where c.table_schema = 'public'
  and (
    c.column_name like 'google_%'
    or c.column_name in ('google_place_id', 'raw_hash', 'source_place_id', 'osm_id', 'wikidata_id')
    or c.table_name in ('raw_places', 'source_runs', 'curated_candidates', 'place_sources')
  )
group by c.table_schema, c.table_name
order by c.table_name;

grant select on public.raw_archive_tables_inventory to authenticated;

-- 2) Curated district mismatch diagnostics (distance between place and assigned district center)
create or replace view public.curated_district_mismatch_report as
select
  p.id as place_id,
  p.name,
  p.slug,
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

-- 3) Repair function: update curated place district_id by nearest district center in same province.
create or replace function public.fix_curated_district_assignments(
  p_max_distance_m integer default 80000,
  p_limit integer default 50000
)
returns table(
  updated_count integer,
  skipped_far_count integer,
  scanned_count integer
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_updated integer := 0;
  v_skipped integer := 0;
  v_scanned integer := 0;
begin
  with candidates as (
    select
      p.id as place_id,
      p.district_id as current_district_id,
      d_near.id as new_district_id,
      st_distance(p.geog, d_near.center_geog) as near_dist
    from public.places p
    join lateral (
      select d2.id, d2.center_geog
      from public.districts d2
      where d2.province_id = p.province_id
      order by d2.center_geog <-> p.geog
      limit 1
    ) d_near on true
    where p.source_kind = 'curated'::public.source_kind
      and p.geog is not null
      and p.province_id is not null
    limit greatest(1, least(200000, coalesce(p_limit, 50000)))
  ),
  upd as (
    update public.places p
    set district_id = c.new_district_id,
        district = d_new.name,
        updated_at = now()
    from candidates c
    join public.districts d_new on d_new.id = c.new_district_id
    where p.id = c.place_id
      and c.new_district_id is not null
      and c.new_district_id is distinct from c.current_district_id
      and c.near_dist <= coalesce(p_max_distance_m, 80000)
    returning p.id
  ),
  stats as (
    select
      (select count(*) from candidates)::int as scanned,
      (select count(*) from upd)::int as updated,
      (
        select count(*)::int
        from candidates c
        where c.new_district_id is null
           or c.near_dist > coalesce(p_max_distance_m, 80000)
      ) as skipped_far
  )
  select scanned, updated, skipped_far
  into v_scanned, v_updated, v_skipped
  from stats;

  return query select v_updated, v_skipped, v_scanned;
end;
$$;

revoke all on function public.fix_curated_district_assignments(integer, integer) from public;
grant execute on function public.fix_curated_district_assignments(integer, integer) to authenticated;
