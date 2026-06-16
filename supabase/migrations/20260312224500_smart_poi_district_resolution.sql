create or replace function public.resolve_poi_district_name_smart(
  p_name text,
  p_city text,
  p_lat double precision,
  p_lng double precision
)
returns text
language sql
stable
as $$
  with province_match as (
    select pr.id
    from public.provinces pr
    where public.normalize_tr_text(pr.name) = public.normalize_tr_text(p_city)
    limit 1
  ),
  named_match as (
    select d.name
    from public.districts d
    join province_match pm on pm.id = d.province_id
    where char_length(public.normalize_tr_text(d.name)) >= 4
      and public.normalize_tr_text(coalesce(p_name, '')) like
          '%' || public.normalize_tr_text(d.name) || '%'
    order by char_length(d.name) desc, d.name asc
    limit 1
  ),
  nearest_match as (
    select d.name
    from public.districts d
    join province_match pm on pm.id = d.province_id
    order by st_distance(
      st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography,
      d.center_geog
    ) asc
    limit 1
  )
  select coalesce(
    (select name from named_match),
    (select name from nearest_match)
  );
$$;

create or replace function public.pois_autofill_city_and_district()
returns trigger
language plpgsql
as $$
declare
  v_scope record;
begin
  if new.lat is null or new.lng is null then
    return new;
  end if;

  select *
  into v_scope
  from public.resolve_poi_admin_scope(new.lat, new.lng);

  if v_scope.distance_m is null or v_scope.distance_m > 120000 then
    return new;
  end if;

  new.city := v_scope.province_name;
  new.district := public.resolve_poi_district_name_smart(
    new.name,
    v_scope.province_name,
    new.lat,
    new.lng
  );
  return new;
end;
$$;

with to_fix as (
  select
    p.id,
    public.resolve_poi_district_name_smart(p.name, p.city, p.lat, p.lng) as district_name
  from public.pois p
  where p.city is not null
    and p.lat is not null
    and p.lng is not null
)
update public.pois p
set
  district = f.district_name,
  updated_at = now()
from to_fix f
where p.id = f.id
  and f.district_name is not null
  and public.normalize_tr_text(coalesce(p.district, '')) <>
      public.normalize_tr_text(coalesce(f.district_name, ''));
