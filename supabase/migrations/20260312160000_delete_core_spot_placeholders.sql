-- Remove placeholder "Core Spot" records from runtime datasets without touching
-- real named places. Records referenced by saved trips are preserved.

with deletable_clean as (
  select pc.id
  from public.places_clean pc
  where pc.name ilike '%Core Spot%'
    and not exists (
      select 1
      from public.trip_stops_clean tsc
      where tsc.place_id = pc.id
    )
),
deletable_pois as (
  select p.id
  from public.pois p
  where p.name ilike '%Core Spot%'
),
deletable_places as (
  select p.id
  from public.places p
  where p.name ilike '%Core Spot%'
    and not exists (
      select 1
      from public.trip_stops ts
      where ts.place_id = p.id
    )
)
delete from public.place_photos
where place_id in (select id from deletable_pois);

with deletable_pois as (
  select p.id
  from public.pois p
  where p.name ilike '%Core Spot%'
)
delete from public.place_checkins
where place_id in (select id from deletable_pois);

with deletable_pois as (
  select p.id
  from public.pois p
  where p.name ilike '%Core Spot%'
)
delete from public.place_community_state
where place_id in (select id from deletable_pois);

with deletable_pois as (
  select p.id
  from public.pois p
  where p.name ilike '%Core Spot%'
)
delete from public.poi_reviews
where poi_id in (select id from deletable_pois);

with deletable_pois as (
  select p.id
  from public.pois p
  where p.name ilike '%Core Spot%'
)
delete from public.poi_signals
where poi_id in (select id from deletable_pois);

with deletable_pois as (
  select p.id
  from public.pois p
  where p.name ilike '%Core Spot%'
)
delete from public.poi_trust_metrics
where poi_id in (select id from deletable_pois);

with deletable_pois as (
  select p.id
  from public.pois p
  where p.name ilike '%Core Spot%'
)
delete from public.poi_live_status
where poi_id in (select id from deletable_pois);

with deletable_pois as (
  select p.id
  from public.pois p
  where p.name ilike '%Core Spot%'
)
delete from public.poi_location_overrides
where poi_id in (select id from deletable_pois);

with deletable_pois as (
  select p.id
  from public.pois p
  where p.name ilike '%Core Spot%'
)
delete from public.pois
where id in (select id from deletable_pois);

with deletable_clean as (
  select pc.id
  from public.places_clean pc
  where pc.name ilike '%Core Spot%'
    and not exists (
      select 1
      from public.trip_stops_clean tsc
      where tsc.place_id = pc.id
    )
)
delete from public.places_clean
where id in (select id from deletable_clean);

with deletable_places as (
  select p.id
  from public.places p
  where p.name ilike '%Core Spot%'
    and not exists (
      select 1
      from public.trip_stops ts
      where ts.place_id = p.id
    )
)
delete from public.places
where id in (select id from deletable_places);
