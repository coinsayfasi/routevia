-- ─────────────────────────────────────────────────────────────────────────────
-- Fix: Re-sync pois.city and pois.district from places_clean (authoritative)
--
-- Root cause: pois_autofill_city_and_district trigger uses district center
-- proximity which is inaccurate for border areas (wrong district centers in DB
-- caused Haburman Köprüsü and other border POIs to be assigned wrong provinces).
-- places_clean.province_id is the authoritative source (set via actual geometry
-- boundary join at import time). This migration re-syncs pois from places_clean.
-- ─────────────────────────────────────────────────────────────────────────────

-- Step 1: Temporarily disable the autofill trigger so our corrections aren't
-- overridden by the centroid-based logic.
alter table public.pois disable trigger trg_pois_autofill_city_and_district;

-- Step 2: Re-sync city and district from places_clean (authoritative province_id)
-- Only touches pois rows that exist in places_clean AND have a mismatched city
-- or district (avoids unnecessary updates to correctly assigned rows).
with correct as (
  select
    pc.id,
    pr.name  as correct_city,
    d.name   as correct_district
  from public.places_clean pc
  join public.provinces pr on pr.id = pc.province_id
  left join public.districts d on d.id = pc.district_id
  where pc.province_id is not null
),
to_fix as (
  select
    p.id,
    c.correct_city,
    c.correct_district
  from public.pois p
  join correct c on c.id = p.id
  where
    public.normalize_tr_text(coalesce(p.city, ''))     <>
      public.normalize_tr_text(coalesce(c.correct_city, ''))
    or
    public.normalize_tr_text(coalesce(p.district, '')) <>
      public.normalize_tr_text(coalesce(c.correct_district, ''))
)
update public.pois p
set
  city        = f.correct_city,
  district    = f.correct_district,
  updated_at  = now()
from to_fix f
where p.id = f.id;

-- Log how many were fixed
do $$
declare
  v_count integer;
begin
  get diagnostics v_count = row_count;
  raise notice 'pois city/district re-synced from places_clean: % rows updated', v_count;
end $$;

-- Step 3: Re-enable the trigger
alter table public.pois enable trigger trg_pois_autofill_city_and_district;

-- Step 4: Fix the trigger to NOT override when city was explicitly synced from
-- places_clean. We update the autofill to only run on NEW inserts (not updates
-- coming from the places_clean sync path), by checking if the pois row already
-- has a matching places_clean entry.
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

  -- If this poi has an authoritative source in places_clean, skip autofill
  -- (places_clean sync trigger handles city/district for those rows).
  if exists (
    select 1 from public.places_clean where id = new.id
  ) then
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
