create or replace function public.resolve_poi_admin_scope(
  p_lat double precision,
  p_lng double precision
)
returns table (
  province_name text,
  district_name text,
  distance_m double precision
)
language sql
stable
as $$
  select
    pr.name as province_name,
    d.name as district_name,
    st_distance(
      st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography,
      d.center_geog
    ) as distance_m
  from public.districts d
  join public.provinces pr on pr.id = d.province_id
  order by distance_m asc
  limit 1
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
  new.district := v_scope.district_name;
  return new;
end;
$$;

drop trigger if exists trg_pois_autofill_city_and_district on public.pois;
create trigger trg_pois_autofill_city_and_district
before insert or update of lat, lng, city, district
on public.pois
for each row
execute function public.pois_autofill_city_and_district();

with resolved as (
  select
    p.id,
    s.province_name,
    s.district_name,
    s.distance_m
  from public.pois p
  cross join lateral public.resolve_poi_admin_scope(p.lat, p.lng) s
  where p.lat is not null
    and p.lng is not null
),
to_fix as (
  select
    r.id,
    r.province_name,
    r.district_name
  from resolved r
  join public.pois p on p.id = r.id
  where r.distance_m <= 120000
    and (
      public.normalize_tr_text(coalesce(p.city, '')) <>
        public.normalize_tr_text(coalesce(r.province_name, ''))
      or public.normalize_tr_text(coalesce(p.district, '')) <>
        public.normalize_tr_text(coalesce(r.district_name, ''))
    )
)
update public.pois p
set
  city = f.province_name,
  district = f.district_name,
  updated_at = now()
from to_fix f
where p.id = f.id;
