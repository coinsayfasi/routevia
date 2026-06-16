create or replace function public.recode_place_coordinate_from_osm(
  p_place_id uuid,
  p_lat double precision,
  p_lng double precision,
  p_verified_by text default null,
  p_note text default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_verified_by text := coalesce(nullif(trim(coalesce(p_verified_by, '')), ''), 'osm_recode');
begin
  update public.places_clean
  set
    geog = st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography,
    coordinate_source = 'osm_verified',
    coordinate_verified_at = now(),
    coordinate_verified_by = v_verified_by,
    updated_at = now()
  where id = p_place_id;

  update public.pois
  set
    lat = p_lat,
    lng = p_lng,
    coordinate_source = 'osm_verified',
    coordinate_verified_at = now(),
    coordinate_verified_by = v_verified_by,
    updated_at = now()
  where id = p_place_id;

  update public.place_coordinate_verification_queue
  set
    status = 'verified',
    source_snapshot = 'osm_verified',
    reviewed_at = now(),
    reviewed_by = v_verified_by,
    note = p_note,
    updated_at = now()
  where place_id = p_place_id;
end;
$$;

grant execute on function public.recode_place_coordinate_from_osm(
  uuid,
  double precision,
  double precision,
  text,
  text
) to authenticated;

grant execute on function public.recode_place_coordinate_from_osm(
  uuid,
  double precision,
  double precision,
  text,
  text
) to service_role;
