-- Auto-correct POI district from coordinates (province-scoped nearest district)
-- Fixes city/district mismatches like "Anitkabir -> Kahramankazan".

create or replace function public.normalize_tr_text(v text)
returns text
language sql
immutable
as $$
  select regexp_replace(
    translate(
      lower(coalesce(v, '')),
      'çğıöşüâîûäëïöüáàéèíìóòúùñ',
      'cgiosuaiuaeiouaaeeiioouun'
    ),
    '[^a-z0-9]+',
    '',
    'g'
  );
$$;

create or replace function public.resolve_poi_district_name(
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
  nearest as (
    select d.name,
           st_distance(
             st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography,
             d.center_geog
           ) as dist_m
    from public.districts d
    join province_match pm on pm.id = d.province_id
    order by dist_m asc
    limit 1
  )
  select case when dist_m <= 120000 then name else null end
  from nearest;
$$;

create or replace function public.pois_autofill_district()
returns trigger
language plpgsql
as $$
declare
  v_resolved text;
begin
  if new.city is null or new.lat is null or new.lng is null then
    return new;
  end if;

  v_resolved := public.resolve_poi_district_name(new.city, new.lat, new.lng);
  if v_resolved is not null then
    new.district := v_resolved;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_pois_autofill_district on public.pois;
create trigger trg_pois_autofill_district
before insert or update of city,lat,lng,district
on public.pois
for each row
execute function public.pois_autofill_district();

-- Backfill all existing POIs where we can confidently resolve district.
with candidate as (
  select
    p.id,
    public.resolve_poi_district_name(p.city, p.lat, p.lng) as district_name
  from public.pois p
  where p.city is not null
    and p.lat is not null
    and p.lng is not null
),
to_fix as (
  select
    c.id,
    c.district_name
  from candidate c
  join public.pois p on p.id = c.id
  where c.district_name is not null
    and public.normalize_tr_text(coalesce(p.district, '')) <>
        public.normalize_tr_text(c.district_name)
)
update public.pois p
set district = f.district_name,
    updated_at = now()
from to_fix f
where p.id = f.id;
