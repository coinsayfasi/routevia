-- Quarantine clearly wrong curated geo assignments without deleting raw data.

create or replace function public.quarantine_curated_geofence_outliers(
  p_distance_m integer default 200000,
  p_limit integer default 50000
)
returns table(
  unpublished_count integer,
  scanned_count integer
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_unpublished integer := 0;
  v_scanned integer := 0;
begin
  with candidates as (
    select
      p.id,
      st_distance(p.geog, d_near.center_geog) as nearest_distance_m
    from public.places p
    join lateral (
      select d2.center_geog
      from public.districts d2
      where d2.province_id = p.province_id
      order by d2.center_geog <-> p.geog
      limit 1
    ) d_near on true
    where p.source_kind = 'curated'::public.source_kind
      and p.geog is not null
      and p.province_id is not null
    limit greatest(1, least(200000, coalesce(p_limit, 50000)))
  ), upd as (
    update public.places p
    set is_published = false,
        published_at = null,
        updated_at = now(),
        source_url = coalesce(p.source_url, 'geo_quarantine')
    from candidates c
    where p.id = c.id
      and c.nearest_distance_m > coalesce(p_distance_m, 200000)
      and p.is_published = true
    returning p.id
  )
  select
    (select count(*)::int from candidates),
    (select count(*)::int from upd)
  into v_scanned, v_unpublished;

  return query select v_unpublished, v_scanned;
end;
$$;

revoke all on function public.quarantine_curated_geofence_outliers(integer, integer) from public;
grant execute on function public.quarantine_curated_geofence_outliers(integer, integer) to authenticated;
