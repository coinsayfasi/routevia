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
    (select id from public.provinces where slug = 'mugla' limit 1),
    null,
    'Oludeniz',
    'oludeniz',
    'beach'::public.place_category,
    'SRID=4326;POINT(29.1402546 36.5708861)'::geography,
    'Oludeniz, Muğla tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','muğla']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-03-13T09:02:20.959Z'::timestamptz,
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
    (select id from public.provinces where slug = 'mugla' limit 1),
    null,
    'Kayakoy',
    'kayakoy',
    'beach'::public.place_category,
    'SRID=4326;POINT(29.0874591 36.5781319)'::geography,
    'Kayakoy, Muğla tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','muğla']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-03-13T09:02:21.925Z'::timestamptz,
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
    (select id from public.provinces where slug = 'mugla' limit 1),
    null,
    'Saklikent',
    'saklikent',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.3877594 36.5572152)'::geography,
    'Saklikent, Muğla tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-03-13T09:02:23.860Z'::timestamptz,
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
    (select id from public.provinces where slug = 'mugla' limit 1),
    null,
    'Kelebekler Vadisi',
    'kelebekler-vadisi',
    'nature'::public.place_category,
    'SRID=4326;POINT(29.1271717 36.4974686)'::geography,
    'Kelebekler Vadisi, Muğla bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','muğla']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-03-13T09:02:24.828Z'::timestamptz,
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
    (select id from public.provinces where slug = 'mugla' limit 1),
    null,
    'Gocek',
    'gocek',
    'beach'::public.place_category,
    'SRID=4326;POINT(28.9422879 36.7537141)'::geography,
    'Gocek, Muğla tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','muğla']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-03-13T09:02:26.101Z'::timestamptz,
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
    (select id from public.provinces where slug = 'mugla' limit 1),
    null,
    'Iztuzu Plaji',
    'iztuzu-plaji',
    'beach'::public.place_category,
    'SRID=4326;POINT(28.6250016 36.7885353)'::geography,
    'Iztuzu Plaji, Muğla tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','muğla']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-03-13T09:02:27.066Z'::timestamptz,
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
    (select id from public.provinces where slug = 'mugla' limit 1),
    null,
    'Kaunos',
    'kaunos',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.6242516 36.8245236)'::geography,
    'Kaunos, Muğla tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-03-13T09:02:28.036Z'::timestamptz,
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
    (select id from public.provinces where slug = 'mugla' limit 1),
    null,
    'Azmak',
    'azmak',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.2368886 36.7159589)'::geography,
    'Azmak, Muğla tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-03-13T09:02:29.000Z'::timestamptz,
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
    (select id from public.provinces where slug = 'mugla' limit 1),
    null,
    'Bodrum Kalesi',
    'bodrum-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.4291029 37.0317673)'::geography,
    'Bodrum Kalesi, Muğla tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-03-13T09:02:30.073Z'::timestamptz,
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
    (select id from public.provinces where slug = 'mugla' limit 1),
    null,
    'Knidos',
    'knidos',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.3739492 36.686356)'::geography,
    'Knidos, Muğla tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-03-13T09:02:31.044Z'::timestamptz,
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
    (select id from public.provinces where slug = 'mugla' limit 1),
    null,
    'Labranda',
    'labranda',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.8199993 37.4188888)'::geography,
    'Labranda, Muğla tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-03-13T09:02:32.017Z'::timestamptz,
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
    (select id from public.provinces where slug = 'mugla' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'fethiye' limit 1),
    'Oludeniz',
    'oludeniz',
    'beach'::public.place_category,
    'SRID=4326;POINT(29.1402546 36.5708861)'::geography,
    'Oludeniz, Fethiye tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','muğla','fethiye']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-03-13T09:02:33.970Z'::timestamptz,
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
    (select id from public.provinces where slug = 'mugla' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'fethiye' limit 1),
    'Kayakoy',
    'kayakoy',
    'beach'::public.place_category,
    'SRID=4326;POINT(29.0874591 36.5781319)'::geography,
    'Kayakoy, Fethiye tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','muğla','fethiye']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-03-13T09:02:34.946Z'::timestamptz,
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
    (select id from public.provinces where slug = 'mugla' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'fethiye' limit 1),
    'Kelebekler Vadisi',
    'kelebekler-vadisi',
    'nature'::public.place_category,
    'SRID=4326;POINT(29.1271717 36.4974686)'::geography,
    'Kelebekler Vadisi, Fethiye bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','muğla','fethiye']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-03-13T09:02:38.062Z'::timestamptz,
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
    (select id from public.provinces where slug = 'mugla' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'fethiye' limit 1),
    'Babadağ',
    'babadag',
    'beach'::public.place_category,
    'SRID=4326;POINT(29.1227057 36.6549053)'::geography,
    'Babadağ, Fethiye tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','muğla','fethiye']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-03-13T09:02:39.851Z'::timestamptz,
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
    (select id from public.provinces where slug = 'mugla' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'fethiye' limit 1),
    'Babadag',
    'babadag',
    'beach'::public.place_category,
    'SRID=4326;POINT(29.1227057 36.6549053)'::geography,
    'Babadag, Fethiye tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','muğla','fethiye']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-03-13T09:02:41.012Z'::timestamptz,
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
