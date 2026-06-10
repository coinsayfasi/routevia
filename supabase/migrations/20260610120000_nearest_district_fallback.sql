-- Nearest-district fallback for verified POIs that still have no district.
--
-- Offshore / coastal POIs (boat tours, coves, islands) have coordinates that
-- fall outside every land admin polygon, so resolve_admin_by_point() returns a
-- null province and the Nominatim self-heal returns no district. Those rows then
-- trip the nightly backend smoke check (MAX_MISSING_DISTRICT = 0).
--
-- Centroid distance is unreliable for large coastal districts (Demre/Kas have
-- inland centroids), so we use the gist-indexed boundary polygons with the KNN
-- <-> operator to find the nearest district *polygon edge*, capped at 60 km so a
-- point far out at sea / outside Turkiye is left alone instead of mis-assigned.

create or replace function public.backfill_missing_districts(p_max int default 2000)
returns int
language plpgsql
security definer
set search_path = public
as $fn$
declare
  r record;
  v_dist text;
  n int := 0;
begin
  for r in
    select id, lat, lng
    from public.pois
    where provenance_verified = true
      and (district is null or district = '')
      and lat is not null and lng is not null
    limit p_max
  loop
    select d.name
      into v_dist
    from public.admin_boundaries_district bd
    join public.districts d on d.id = bd.district_id,
         lateral (select st_setsrid(st_makepoint(r.lng, r.lat), 4326) as g) pt
    where st_dwithin(bd.geom::geography, pt.g::geography, 60000)
    order by bd.geom <-> pt.g
    limit 1;

    if v_dist is not null then
      update public.pois set district = v_dist where id = r.id;
      n := n + 1;
    end if;
  end loop;

  return n;
end;
$fn$;

revoke all on function public.backfill_missing_districts(int) from anon, authenticated;
grant execute on function public.backfill_missing_districts(int) to service_role;

-- One-time backfill of any rows currently missing a district.
select public.backfill_missing_districts(2000);
