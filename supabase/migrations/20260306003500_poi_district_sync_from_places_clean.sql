-- Revert nearest-center district autofill (district center seed can be noisy)
drop trigger if exists trg_pois_autofill_district on public.pois;
drop function if exists public.pois_autofill_district();
drop function if exists public.resolve_poi_district_name(text, double precision, double precision);

-- Canonical sync: use clean curated dataset ids when available.
-- places_clean carries authoritative province_id/district_id relations.
create or replace function public.sync_poi_city_district_from_places_clean()
returns integer
language plpgsql
as $$
declare
  v_count integer := 0;
begin
  with src as (
    select
      pc.id as poi_id,
      pr.name as city_name,
      d.name as district_name
    from public.places_clean pc
    join public.provinces pr on pr.id = pc.province_id
    left join public.districts d on d.id = pc.district_id
  ),
  upd as (
    update public.pois p
    set city = s.city_name,
        district = s.district_name,
        updated_at = now()
    from src s
    where p.id = s.poi_id
      and (
        coalesce(p.city, '') <> coalesce(s.city_name, '')
        or coalesce(p.district, '') <> coalesce(s.district_name, '')
      )
    returning 1
  )
  select count(*) into v_count from upd;

  return v_count;
end;
$$;

-- Run once now.
select public.sync_poi_city_district_from_places_clean();
