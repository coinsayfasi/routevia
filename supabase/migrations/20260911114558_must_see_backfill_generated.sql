with upserted as (
  insert into public.places_clean (
    province_id,
    district_id,
    name,
    slug,
    category,
    geog,
    short_summary,
    best_time,
    duration_min,
    tags,
    popularity_score,
    coordinate_source,
    coordinate_verified_at,
    coordinate_verified_by
  )
  values (
    (select id from public.provinces where slug = 'adana' limit 1),
    null,
    'Sabanci Merkez Camii',
    'sabanci-merkez-camii',
    'historical'::public.place_category,
    'SRID=4326;POINT(35.3340711 36.9916917)'::geography,
    'Sabanci Merkez Camii, Adana tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','adana']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:45:53.732Z'::timestamptz,
    'must_see_backfill_script'
  )
  on conflict (province_id, slug) do update
  set
    popularity_score = greatest(public.places_clean.popularity_score, excluded.popularity_score),
    tags = array(
      select distinct tag
      from unnest(coalesce(public.places_clean.tags, '{}'::text[]) || excluded.tags) as tag
    )
  returning id
)
insert into public.place_details_clean (
  place_id,
  history_bullets,
  eat_drink_bullets,
  tips_bullets
)
select id, array[]::text[], array[]::text[], array[]::text[]
from upserted
on conflict (place_id) do nothing;

with upserted as (
  insert into public.places_clean (
    province_id,
    district_id,
    name,
    slug,
    category,
    geog,
    short_summary,
    best_time,
    duration_min,
    tags,
    popularity_score,
    coordinate_source,
    coordinate_verified_at,
    coordinate_verified_by
  )
  values (
    (select id from public.provinces where slug = 'adana' limit 1),
    null,
    'Varda Koprusu',
    'varda-koprusu',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.9766149 37.244329)'::geography,
    'Varda Koprusu, Adana tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','adana']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:45:56.672Z'::timestamptz,
    'must_see_backfill_script'
  )
  on conflict (province_id, slug) do update
  set
    popularity_score = greatest(public.places_clean.popularity_score, excluded.popularity_score),
    tags = array(
      select distinct tag
      from unnest(coalesce(public.places_clean.tags, '{}'::text[]) || excluded.tags) as tag
    )
  returning id
)
insert into public.place_details_clean (
  place_id,
  history_bullets,
  eat_drink_bullets,
  tips_bullets
)
select id, array[]::text[], array[]::text[], array[]::text[]
from upserted
on conflict (place_id) do nothing;
