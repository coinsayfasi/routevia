create or replace function public.sync_poi_from_places_clean()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_city text;
  v_district text;
  v_source text;
  v_verified boolean;
begin
  select name into v_city
  from public.provinces
  where id = new.province_id;

  select name into v_district
  from public.districts
  where id = new.district_id;

  v_source := case
    when new.coordinate_source = 'user_verified' then 'user'
    else 'osm'
  end;

  v_verified := new.coordinate_source <> 'legacy_curated_unverified';

  insert into public.pois (
    id,
    name,
    category,
    lat,
    lng,
    city,
    district,
    tags,
    source,
    provenance_verified,
    provenance_checked_at,
    coordinate_source,
    coordinate_verified_at,
    coordinate_verified_by,
    updated_at
  )
  values (
    new.id,
    new.name,
    new.category::text,
    st_y(new.geog::geometry),
    st_x(new.geog::geometry),
    v_city,
    v_district,
    to_jsonb(coalesce(new.tags, '{}'::text[])),
    v_source,
    v_verified,
    case
      when v_verified then coalesce(new.coordinate_verified_at, now())
      else null
    end,
    new.coordinate_source,
    new.coordinate_verified_at,
    new.coordinate_verified_by,
    now()
  )
  on conflict (id) do update
  set
    name = excluded.name,
    category = excluded.category,
    lat = excluded.lat,
    lng = excluded.lng,
    city = excluded.city,
    district = excluded.district,
    tags = excluded.tags,
    source = excluded.source,
    provenance_verified = excluded.provenance_verified,
    provenance_checked_at = excluded.provenance_checked_at,
    coordinate_source = excluded.coordinate_source,
    coordinate_verified_at = excluded.coordinate_verified_at,
    coordinate_verified_by = excluded.coordinate_verified_by,
    updated_at = now();

  insert into public.place_coordinate_verification_queue (
    place_id,
    status,
    reason,
    source_snapshot,
    reviewed_at,
    reviewed_by,
    note
  )
  values (
    new.id,
    case
      when new.coordinate_source = 'legacy_curated_unverified' then 'pending'
      else 'verified'
    end,
    case
      when new.coordinate_source = 'legacy_curated_unverified' then 'legacy_curated_coordinate'
      else 'coordinate_verified'
    end,
    new.coordinate_source,
    case
      when new.coordinate_source = 'legacy_curated_unverified' then null
      else coalesce(new.coordinate_verified_at, now())
    end,
    case
      when new.coordinate_source = 'legacy_curated_unverified' then null
      else new.coordinate_verified_by
    end,
    case
      when new.coordinate_source = 'legacy_curated_unverified' then null
      else 'synced_from_places_clean'
    end
  )
  on conflict (place_id) do update
  set
    status = excluded.status,
    reason = excluded.reason,
    source_snapshot = excluded.source_snapshot,
    reviewed_at = excluded.reviewed_at,
    reviewed_by = excluded.reviewed_by,
    note = excluded.note,
    updated_at = now();

  return new;
end;
$$;

drop trigger if exists trg_places_clean_coordinate_trust_sync
  on public.places_clean;
drop trigger if exists trg_places_clean_sync_poi
  on public.places_clean;

create trigger trg_places_clean_sync_poi
after insert or update of
  province_id,
  district_id,
  name,
  category,
  geog,
  tags,
  coordinate_source,
  coordinate_verified_at,
  coordinate_verified_by
on public.places_clean
for each row execute function public.sync_poi_from_places_clean();

insert into public.pois (
  id,
  name,
  category,
  lat,
  lng,
  city,
  district,
  tags,
  source,
  provenance_verified,
  provenance_checked_at,
  coordinate_source,
  coordinate_verified_at,
  coordinate_verified_by,
  created_at,
  updated_at
)
select
  pc.id,
  pc.name,
  pc.category::text,
  st_y(pc.geog::geometry),
  st_x(pc.geog::geometry),
  pr.name,
  d.name,
  to_jsonb(coalesce(pc.tags, '{}'::text[])),
  case
    when pc.coordinate_source = 'user_verified' then 'user'
    else 'osm'
  end,
  pc.coordinate_source <> 'legacy_curated_unverified',
  case
    when pc.coordinate_source <> 'legacy_curated_unverified' then coalesce(pc.coordinate_verified_at, now())
    else null
  end,
  pc.coordinate_source,
  pc.coordinate_verified_at,
  pc.coordinate_verified_by,
  now(),
  now()
from public.places_clean pc
join public.provinces pr on pr.id = pc.province_id
left join public.districts d on d.id = pc.district_id
on conflict (id) do update
set
  name = excluded.name,
  category = excluded.category,
  lat = excluded.lat,
  lng = excluded.lng,
  city = excluded.city,
  district = excluded.district,
  tags = excluded.tags,
  source = excluded.source,
  provenance_verified = excluded.provenance_verified,
  provenance_checked_at = excluded.provenance_checked_at,
  coordinate_source = excluded.coordinate_source,
  coordinate_verified_at = excluded.coordinate_verified_at,
  coordinate_verified_by = excluded.coordinate_verified_by,
  updated_at = now();
