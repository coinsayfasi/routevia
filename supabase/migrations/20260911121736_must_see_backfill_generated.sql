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
    '2026-09-11T11:46:11.899Z'::timestamptz,
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
    '2026-09-11T11:46:13.537Z'::timestamptz,
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
    (select id from public.provinces where slug = 'adiyaman' limit 1),
    null,
    'Nemrut',
    'nemrut',
    'historical'::public.place_category,
    'SRID=4326;POINT(38.7409358 37.9803197)'::geography,
    'Nemrut, Adıyaman tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','adıyaman']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:46:15.335Z'::timestamptz,
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
    (select id from public.provinces where slug = 'adiyaman' limit 1),
    null,
    'Cendere Koprusu',
    'cendere-koprusu',
    'historical'::public.place_category,
    'SRID=4326;POINT(38.6119236 37.9333966)'::geography,
    'Cendere Koprusu, Adıyaman tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','adıyaman']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:46:17.549Z'::timestamptz,
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
    (select id from public.provinces where slug = 'adiyaman' limit 1),
    null,
    'Karakus Tumulusu',
    'karakus-tumulusu',
    'historical'::public.place_category,
    'SRID=4326;POINT(38.5879219 37.8693115)'::geography,
    'Karakus Tumulusu, Adıyaman tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','adıyaman']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:46:19.307Z'::timestamptz,
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
    (select id from public.provinces where slug = 'afyonkarahisar' limit 1),
    null,
    'Frig Vadisi',
    'frig-vadisi',
    'nature'::public.place_category,
    'SRID=4326;POINT(30.4192673 39.0882153)'::geography,
    'Frig Vadisi, Afyonkarahisar bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','afyonkarahisar']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:46:22.651Z'::timestamptz,
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
    (select id from public.provinces where slug = 'afyonkarahisar' limit 1),
    null,
    'Gazligol',
    'gazligol',
    'nature'::public.place_category,
    'SRID=4326;POINT(30.5007014 38.9319316)'::geography,
    'Gazligol, Afyonkarahisar bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','afyonkarahisar']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:46:24.502Z'::timestamptz,
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
    (select id from public.provinces where slug = 'agri' limit 1),
    null,
    'Ishak Pasa Sarayi',
    'ishak-pasa-sarayi',
    'historical'::public.place_category,
    'SRID=4326;POINT(44.1296852 39.5203827)'::geography,
    'Ishak Pasa Sarayi, Ağrı tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','ağrı']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:46:26.242Z'::timestamptz,
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
    (select id from public.provinces where slug = 'agri' limit 1),
    null,
    'Agri Dagi',
    'agri-dagi',
    'historical'::public.place_category,
    'SRID=4326;POINT(44.4138156 39.6482053)'::geography,
    'Agri Dagi, Ağrı tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','ağrı']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:46:28.120Z'::timestamptz,
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
    (select id from public.provinces where slug = 'aksaray' limit 1),
    null,
    'Ihlara Vadisi',
    'ihlara-vadisi',
    'nature'::public.place_category,
    'SRID=4326;POINT(34.3010469 38.2559485)'::geography,
    'Ihlara Vadisi, Aksaray bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','aksaray']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:46:31.317Z'::timestamptz,
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
    (select id from public.provinces where slug = 'aksaray' limit 1),
    null,
    'Sultanhani',
    'sultanhani',
    'historical'::public.place_category,
    'SRID=4326;POINT(33.5489796 38.2474175)'::geography,
    'Sultanhani, Aksaray tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','aksaray']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:46:33.604Z'::timestamptz,
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
    (select id from public.provinces where slug = 'aksaray' limit 1),
    null,
    'Hasan Dagi',
    'hasan-dagi',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.1651126 38.1265274)'::geography,
    'Hasan Dagi, Aksaray tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','aksaray']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:46:35.359Z'::timestamptz,
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
    (select id from public.provinces where slug = 'amasya' limit 1),
    null,
    'Kral Kaya Mezarlari',
    'kral-kaya-mezarlari',
    'historical'::public.place_category,
    'SRID=4326;POINT(35.8306128 40.653462)'::geography,
    'Kral Kaya Mezarlari, Amasya tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','amasya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:46:37.115Z'::timestamptz,
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
    (select id from public.provinces where slug = 'amasya' limit 1),
    null,
    'Borabay Golu',
    'borabay-golu',
    'nature'::public.place_category,
    'SRID=4326;POINT(36.1543085 40.8037442)'::geography,
    'Borabay Golu, Amasya bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','amasya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:46:40.456Z'::timestamptz,
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
    (select id from public.provinces where slug = 'ankara' limit 1),
    null,
    'Anitkabir',
    'anitkabir',
    'historical'::public.place_category,
    'SRID=4326;POINT(32.8365635 39.9267385)'::geography,
    'Anitkabir, Ankara tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','ankara']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:46:42.354Z'::timestamptz,
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
    (select id from public.provinces where slug = 'ankara' limit 1),
    null,
    'Atakule',
    'atakule',
    'viewpoint'::public.place_category,
    'SRID=4326;POINT(32.8561367 39.8861418)'::geography,
    'Atakule, Ankara civarinda manzara ve fotograf icin one cikan ikonik bir noktadir.',
    'sunset'::public.best_time,
    60,
    array['must-see','iconic','ankara']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:46:44.176Z'::timestamptz,
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
    (select id from public.provinces where slug = 'ankara' limit 1),
    null,
    'Hamamonu',
    'hamamonu',
    'historical'::public.place_category,
    'SRID=4326;POINT(32.8660778 39.9334686)'::geography,
    'Hamamonu, Ankara tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','ankara']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:46:46.249Z'::timestamptz,
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
    (select id from public.provinces where slug = 'ankara' limit 1),
    null,
    'Ankara Kalesi',
    'ankara-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(32.865427 39.9414931)'::geography,
    'Ankara Kalesi, Ankara tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','ankara']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:46:48.310Z'::timestamptz,
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
    (select id from public.provinces where slug = 'ankara' limit 1),
    null,
    'Anadolu Medeniyetleri Muzesi',
    'anadolu-medeniyetleri-muzesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(32.8617618 39.9379477)'::geography,
    'Anadolu Medeniyetleri Muzesi, Ankara tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','ankara']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:46:51.105Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    null,
    'Kaleici',
    'kaleici',
    'historical'::public.place_category,
    'SRID=4326;POINT(30.707878 36.8840816)'::geography,
    'Kaleici, Antalya tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','antalya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:46:52.910Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    null,
    'Duden Selalesi',
    'duden-selalesi',
    'nature'::public.place_category,
    'SRID=4326;POINT(30.726664 36.9648286)'::geography,
    'Duden Selalesi, Antalya bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','antalya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:46:54.826Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    null,
    'Olympos',
    'olympos',
    'historical'::public.place_category,
    'SRID=4326;POINT(30.4735644 36.3950121)'::geography,
    'Olympos, Antalya tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','antalya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:46:57.005Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    null,
    'Aspendos',
    'aspendos',
    'historical'::public.place_category,
    'SRID=4326;POINT(31.1696915 36.940401)'::geography,
    'Aspendos, Antalya tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','antalya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:47:00.295Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    null,
    'Alanya Kalesi',
    'alanya-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(31.9905642 36.5331062)'::geography,
    'Alanya Kalesi, Antalya tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','antalya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:47:02.757Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    null,
    'Koprulu Kanyon',
    'koprulu-kanyon',
    'nature'::public.place_category,
    'SRID=4326;POINT(31.1804494 37.1876855)'::geography,
    'Koprulu Kanyon, Antalya bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','antalya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:47:04.593Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    null,
    'Termessos',
    'termessos',
    'historical'::public.place_category,
    'SRID=4326;POINT(30.4626335 36.9841843)'::geography,
    'Termessos, Antalya tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','antalya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:47:08.416Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    null,
    'Kekova',
    'kekova',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.877452 36.1824129)'::geography,
    'Kekova, Antalya tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','antalya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:47:10.722Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    null,
    'Myra',
    'myra',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.9852046 36.2587484)'::geography,
    'Myra, Antalya tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','antalya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:47:13.270Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    null,
    'Kaputas',
    'kaputas',
    'beach'::public.place_category,
    'SRID=4326;POINT(29.4491601 36.2288242)'::geography,
    'Kaputas, Antalya tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','antalya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:47:15.079Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    null,
    'Patara',
    'patara',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.3179562 36.2611865)'::geography,
    'Patara, Antalya tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','antalya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:47:16.949Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    null,
    'Side',
    'side',
    'historical'::public.place_category,
    'SRID=4326;POINT(31.3892197 36.7664439)'::geography,
    'Side, Antalya tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','antalya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:47:18.975Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    null,
    'Manavgat Selalesi',
    'manavgat-selalesi',
    'nature'::public.place_category,
    'SRID=4326;POINT(31.4544432 36.8135429)'::geography,
    'Manavgat Selalesi, Antalya bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','antalya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:47:22.177Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    null,
    'Dim Cay',
    'dim-cay',
    'historical'::public.place_category,
    'SRID=4326;POINT(32.0547341 36.5223957)'::geography,
    'Dim Cay, Antalya tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','antalya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:47:24.702Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    null,
    'Karain Magarasi',
    'karain-magarasi',
    'nature'::public.place_category,
    'SRID=4326;POINT(30.5706249 37.077831)'::geography,
    'Karain Magarasi, Antalya bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','antalya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:47:28.645Z'::timestamptz,
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
    (select id from public.provinces where slug = 'ardahan' limit 1),
    null,
    'Seytan Kalesi',
    'seytan-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(43.1320637 41.1540647)'::geography,
    'Seytan Kalesi, Ardahan tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','ardahan']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:47:32.453Z'::timestamptz,
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
    (select id from public.provinces where slug = 'ardahan' limit 1),
    null,
    'Ardahan Kalesi',
    'ardahan-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(42.7037085 41.1180768)'::geography,
    'Ardahan Kalesi, Ardahan tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','ardahan']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:47:34.669Z'::timestamptz,
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
    (select id from public.provinces where slug = 'artvin' limit 1),
    null,
    'Karagol',
    'karagol',
    'nature'::public.place_category,
    'SRID=4326;POINT(41.8542248 41.385221)'::geography,
    'Karagol, Artvin bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','artvin']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:47:36.853Z'::timestamptz,
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
    (select id from public.provinces where slug = 'artvin' limit 1),
    null,
    'Mencuna Selalesi',
    'mencuna-selalesi',
    'nature'::public.place_category,
    'SRID=4326;POINT(41.3519867 41.254658)'::geography,
    'Mencuna Selalesi, Artvin bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','artvin']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:47:39.053Z'::timestamptz,
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
    (select id from public.provinces where slug = 'artvin' limit 1),
    null,
    'Hatila Vadisi',
    'hatila-vadisi',
    'nature'::public.place_category,
    'SRID=4326;POINT(41.6513404 41.14015)'::geography,
    'Hatila Vadisi, Artvin bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','artvin']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:47:41.023Z'::timestamptz,
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
    (select id from public.provinces where slug = 'aydin' limit 1),
    null,
    'Dilek Yarimadasi',
    'dilek-yarimadasi',
    'beach'::public.place_category,
    'SRID=4326;POINT(27.0877986 37.6595976)'::geography,
    'Dilek Yarimadasi, Aydın tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','aydın']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:47:46.132Z'::timestamptz,
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
    (select id from public.provinces where slug = 'aydin' limit 1),
    null,
    'Priene',
    'priene',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.2959755 37.6613182)'::geography,
    'Priene, Aydın tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','aydın']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:47:51.686Z'::timestamptz,
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
    (select id from public.provinces where slug = 'aydin' limit 1),
    null,
    'Didim',
    'didim',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.2684841 37.3696865)'::geography,
    'Didim, Aydın tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','aydın']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:47:53.805Z'::timestamptz,
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
    (select id from public.provinces where slug = 'aydin' limit 1),
    null,
    'Apollon Tapinagi',
    'apollon-tapinagi',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.25636 37.3849478)'::geography,
    'Apollon Tapinagi, Aydın tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','aydın']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:47:55.663Z'::timestamptz,
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
    (select id from public.provinces where slug = 'aydin' limit 1),
    null,
    'Milet',
    'milet',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.2798246 37.5318313)'::geography,
    'Milet, Aydın tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','aydın']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:47:57.564Z'::timestamptz,
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
    (select id from public.provinces where slug = 'aydin' limit 1),
    null,
    'Nysa',
    'nysa',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.1456496 37.9031225)'::geography,
    'Nysa, Aydın tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','aydın']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:47:59.920Z'::timestamptz,
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
    (select id from public.provinces where slug = 'balikesir' limit 1),
    null,
    'Kaz Daglari',
    'kaz-daglari',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.7637243 39.672853)'::geography,
    'Kaz Daglari, Balıkesir tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','balıkesir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:48:03.701Z'::timestamptz,
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
    (select id from public.provinces where slug = 'balikesir' limit 1),
    null,
    'Seytan Sofrasi',
    'seytan-sofrasi',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.6429783 39.2887541)'::geography,
    'Seytan Sofrasi, Balıkesir tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','balıkesir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:48:06.386Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bartin' limit 1),
    null,
    'Amasra',
    'amasra',
    'historical'::public.place_category,
    'SRID=4326;POINT(32.3866959 41.7489175)'::geography,
    'Amasra, Bartın tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','bartın']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:48:08.706Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bartin' limit 1),
    null,
    'Inkumu',
    'inkumu',
    'historical'::public.place_category,
    'SRID=4326;POINT(32.2174088 41.6602775)'::geography,
    'Inkumu, Bartın tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','bartın']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:48:10.521Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bartin' limit 1),
    null,
    'Guzelcehisar',
    'guzelcehisar',
    'historical'::public.place_category,
    'SRID=4326;POINT(32.2088589 41.6471486)'::geography,
    'Guzelcehisar, Bartın tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','bartın']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:48:12.709Z'::timestamptz,
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
    (select id from public.provinces where slug = 'batman' limit 1),
    null,
    'Hasankeyf',
    'hasankeyf',
    'historical'::public.place_category,
    'SRID=4326;POINT(41.4160863 37.7304689)'::geography,
    'Hasankeyf, Batman tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','batman']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:48:14.415Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bayburt' limit 1),
    null,
    'Bayburt Kalesi',
    'bayburt-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(40.2297903 40.2634463)'::geography,
    'Bayburt Kalesi, Bayburt tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','bayburt']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:48:20.298Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bayburt' limit 1),
    null,
    'Baksi Muzesi',
    'baksi-muzesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(40.5662973 40.3856758)'::geography,
    'Baksi Muzesi, Bayburt tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','bayburt']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:48:24.069Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bilecik' limit 1),
    null,
    'Seyh Edebali',
    'seyh-edebali',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.9668186 40.1900369)'::geography,
    'Seyh Edebali, Bilecik tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','bilecik']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:48:25.871Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bingol' limit 1),
    null,
    'Hesarek',
    'hesarek',
    'historical'::public.place_category,
    'SRID=4326;POINT(40.2889399 38.888868)'::geography,
    'Hesarek, Bingöl tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','bingöl']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:48:31.803Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bitlis' limit 1),
    null,
    'Nemrut Krater Golu',
    'nemrut-krater-golu',
    'nature'::public.place_category,
    'SRID=4326;POINT(42.2385856 38.6319008)'::geography,
    'Nemrut Krater Golu, Bitlis bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','bitlis']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:48:36.418Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bitlis' limit 1),
    null,
    'Ahlat Selcuklu Mezarligi',
    'ahlat-selcuklu-mezarligi',
    'historical'::public.place_category,
    'SRID=4326;POINT(42.4580318 38.7420931)'::geography,
    'Ahlat Selcuklu Mezarligi, Bitlis tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','bitlis']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:48:38.515Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bitlis' limit 1),
    null,
    'Bitlis Kalesi',
    'bitlis-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(42.1077212 38.4016884)'::geography,
    'Bitlis Kalesi, Bitlis tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','bitlis']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:48:40.948Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bolu' limit 1),
    null,
    'Abant',
    'abant',
    'historical'::public.place_category,
    'SRID=4326;POINT(31.4743986 40.7220644)'::geography,
    'Abant, Bolu tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','bolu']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:48:42.607Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bolu' limit 1),
    null,
    'Golcuk',
    'golcuk',
    'nature'::public.place_category,
    'SRID=4326;POINT(31.6980971 40.8169668)'::geography,
    'Golcuk, Bolu bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','bolu']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:48:45.009Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bolu' limit 1),
    null,
    'Yedigoller',
    'yedigoller',
    'nature'::public.place_category,
    'SRID=4326;POINT(31.7477355 40.9433239)'::geography,
    'Yedigoller, Bolu bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','bolu']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:48:46.958Z'::timestamptz,
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
    (select id from public.provinces where slug = 'burdur' limit 1),
    null,
    'Salda Golu',
    'salda-golu',
    'nature'::public.place_category,
    'SRID=4326;POINT(29.6816127 37.5475982)'::geography,
    'Salda Golu, Burdur bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','burdur']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:48:48.772Z'::timestamptz,
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
    (select id from public.provinces where slug = 'burdur' limit 1),
    null,
    'Sagalassos',
    'sagalassos',
    'historical'::public.place_category,
    'SRID=4326;POINT(30.5176212 37.6753135)'::geography,
    'Sagalassos, Burdur tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','burdur']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:48:50.480Z'::timestamptz,
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
    (select id from public.provinces where slug = 'burdur' limit 1),
    null,
    'Insuyu Magarasi',
    'insuyu-magarasi',
    'nature'::public.place_category,
    'SRID=4326;POINT(30.3757774 37.6597429)'::geography,
    'Insuyu Magarasi, Burdur bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','burdur']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:48:52.408Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bursa' limit 1),
    null,
    'Uludag',
    'uludag',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.2220098 40.0705295)'::geography,
    'Uludag, Bursa tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','bursa']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:48:54.097Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bursa' limit 1),
    null,
    'Cumalikizik',
    'cumalikizik',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.1726885 40.1752128)'::geography,
    'Cumalikizik, Bursa tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','bursa']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:48:56.257Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bursa' limit 1),
    null,
    'Ulu Cami',
    'ulu-cami',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.0618995 40.1838059)'::geography,
    'Ulu Cami, Bursa tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','bursa']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:48:58.400Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bursa' limit 1),
    null,
    'Golyazi',
    'golyazi',
    'nature'::public.place_category,
    'SRID=4326;POINT(28.6775511 40.1653978)'::geography,
    'Golyazi, Bursa bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','bursa']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:49:00.254Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bursa' limit 1),
    null,
    'Tirilye',
    'tirilye',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.7962239 40.3927446)'::geography,
    'Tirilye, Bursa tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','bursa']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:49:02.355Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bursa' limit 1),
    null,
    'Mudanya',
    'mudanya',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.8837929 40.3752582)'::geography,
    'Mudanya, Bursa tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','bursa']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:49:04.677Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bursa' limit 1),
    null,
    'Iznik',
    'iznik',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.7223732 40.4303445)'::geography,
    'Iznik, Bursa tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','bursa']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:49:06.585Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bursa' limit 1),
    null,
    'Iznik Golu',
    'iznik-golu',
    'nature'::public.place_category,
    'SRID=4326;POINT(29.5270323 40.4429575)'::geography,
    'Iznik Golu, Bursa bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','bursa']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:49:08.415Z'::timestamptz,
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
    (select id from public.provinces where slug = 'canakkale' limit 1),
    null,
    'Troya',
    'troya',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.2380175 39.957374)'::geography,
    'Troya, Çanakkale tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','çanakkale']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:49:10.303Z'::timestamptz,
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
    (select id from public.provinces where slug = 'canakkale' limit 1),
    null,
    'Assos',
    'assos',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.3361336 39.4889415)'::geography,
    'Assos, Çanakkale tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','çanakkale']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:49:12.155Z'::timestamptz,
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
    (select id from public.provinces where slug = 'canakkale' limit 1),
    null,
    'Kilitbahir',
    'kilitbahir',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.3779734 40.1467789)'::geography,
    'Kilitbahir, Çanakkale tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','çanakkale']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:49:13.970Z'::timestamptz,
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
    (select id from public.provinces where slug = 'canakkale' limit 1),
    null,
    'Bozcaada',
    'bozcaada',
    'beach'::public.place_category,
    'SRID=4326;POINT(26.0701917 39.8347344)'::geography,
    'Bozcaada, Çanakkale tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','çanakkale']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:49:15.664Z'::timestamptz,
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
    (select id from public.provinces where slug = 'cankiri' limit 1),
    null,
    'Tuz Magarasi',
    'tuz-magarasi',
    'nature'::public.place_category,
    'SRID=4326;POINT(33.7600591 40.54258)'::geography,
    'Tuz Magarasi, Çankırı bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','çankırı']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:49:17.640Z'::timestamptz,
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
    (select id from public.provinces where slug = 'cankiri' limit 1),
    null,
    'Ilgaz',
    'ilgaz',
    'historical'::public.place_category,
    'SRID=4326;POINT(33.6253409 40.924887)'::geography,
    'Ilgaz, Çankırı tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','çankırı']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:49:19.791Z'::timestamptz,
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
    (select id from public.provinces where slug = 'cankiri' limit 1),
    null,
    'Cankiri Kalesi',
    'cankiri-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(33.6165658 40.6081917)'::geography,
    'Cankiri Kalesi, Çankırı tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','çankırı']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:49:21.476Z'::timestamptz,
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
    (select id from public.provinces where slug = 'corum' limit 1),
    null,
    'Hattusa',
    'hattusa',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.6197357 40.0222167)'::geography,
    'Hattusa, Çorum tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','çorum']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:49:23.985Z'::timestamptz,
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
    (select id from public.provinces where slug = 'corum' limit 1),
    null,
    'Alacahoyuk',
    'alacahoyuk',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.6950961 40.2345193)'::geography,
    'Alacahoyuk, Çorum tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','çorum']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:49:27.348Z'::timestamptz,
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
    (select id from public.provinces where slug = 'denizli' limit 1),
    null,
    'Pamukkale',
    'pamukkale',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.1217529 37.9200382)'::geography,
    'Pamukkale, Denizli tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','denizli']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:49:30.646Z'::timestamptz,
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
    (select id from public.provinces where slug = 'denizli' limit 1),
    null,
    'Hierapolis',
    'hierapolis',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.1263634 37.9309549)'::geography,
    'Hierapolis, Denizli tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','denizli']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:49:32.554Z'::timestamptz,
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
    (select id from public.provinces where slug = 'denizli' limit 1),
    null,
    'Laodikya',
    'laodikya',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.0903454 37.7842293)'::geography,
    'Laodikya, Denizli tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','denizli']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:49:34.427Z'::timestamptz,
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
    (select id from public.provinces where slug = 'diyarbakir' limit 1),
    null,
    'Diyarbakir Surlari',
    'diyarbakir-surlari',
    'historical'::public.place_category,
    'SRID=4326;POINT(40.2371428 37.9162655)'::geography,
    'Diyarbakir Surlari, Diyarbakır tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','diyarbakır']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:49:36.046Z'::timestamptz,
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
    (select id from public.provinces where slug = 'diyarbakir' limit 1),
    null,
    'On Gozlu Kopru',
    'on-gozlu-kopru',
    'historical'::public.place_category,
    'SRID=4326;POINT(40.2288931 37.8871651)'::geography,
    'On Gozlu Kopru, Diyarbakır tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','diyarbakır']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:49:37.703Z'::timestamptz,
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
    (select id from public.provinces where slug = 'diyarbakir' limit 1),
    null,
    'Hasan Pasa Hani',
    'hasan-pasa-hani',
    'historical'::public.place_category,
    'SRID=4326;POINT(40.2374267 37.9127242)'::geography,
    'Hasan Pasa Hani, Diyarbakır tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','diyarbakır']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:49:39.489Z'::timestamptz,
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
    (select id from public.provinces where slug = 'duzce' limit 1),
    null,
    'Akcakoca',
    'akcakoca',
    'historical'::public.place_category,
    'SRID=4326;POINT(31.1239833 41.0882278)'::geography,
    'Akcakoca, Düzce tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','düzce']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:49:41.247Z'::timestamptz,
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
    (select id from public.provinces where slug = 'duzce' limit 1),
    null,
    'Guzeldere Selalesi',
    'guzeldere-selalesi',
    'nature'::public.place_category,
    'SRID=4326;POINT(31.0498384 40.7238596)'::geography,
    'Guzeldere Selalesi, Düzce bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','düzce']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:49:43.089Z'::timestamptz,
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
    (select id from public.provinces where slug = 'duzce' limit 1),
    null,
    'Aydinpinar',
    'aydinpinar',
    'historical'::public.place_category,
    'SRID=4326;POINT(31.1085001 40.7604494)'::geography,
    'Aydinpinar, Düzce tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','düzce']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:49:44.830Z'::timestamptz,
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
    (select id from public.provinces where slug = 'edirne' limit 1),
    null,
    'Selimiye',
    'selimiye',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.5593409 41.6781393)'::geography,
    'Selimiye, Edirne tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','edirne']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:49:47.118Z'::timestamptz,
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
    (select id from public.provinces where slug = 'edirne' limit 1),
    null,
    'Meric Koprusu',
    'meric-koprusu',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.55212 41.663416)'::geography,
    'Meric Koprusu, Edirne tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','edirne']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:49:48.801Z'::timestamptz,
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
    (select id from public.provinces where slug = 'edirne' limit 1),
    null,
    'Edirne Sarayi',
    'edirne-sarayi',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.5551539 41.6910992)'::geography,
    'Edirne Sarayi, Edirne tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','edirne']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:49:50.723Z'::timestamptz,
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
    (select id from public.provinces where slug = 'elazig' limit 1),
    null,
    'Buzluk Magarasi',
    'buzluk-magarasi',
    'nature'::public.place_category,
    'SRID=4326;POINT(39.2827641 38.7361054)'::geography,
    'Buzluk Magarasi, Elazığ bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','elazığ']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:49:56.407Z'::timestamptz,
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
    (select id from public.provinces where slug = 'erzincan' limit 1),
    null,
    'Kemaliye',
    'kemaliye',
    'historical'::public.place_category,
    'SRID=4326;POINT(38.4965266 39.2620966)'::geography,
    'Kemaliye, Erzincan tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','erzincan']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:50:03.108Z'::timestamptz,
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
    (select id from public.provinces where slug = 'erzincan' limit 1),
    null,
    'Karanlik Kanyon',
    'karanlik-kanyon',
    'nature'::public.place_category,
    'SRID=4326;POINT(38.4881041 39.2847725)'::geography,
    'Karanlik Kanyon, Erzincan bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','erzincan']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:50:04.952Z'::timestamptz,
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
    (select id from public.provinces where slug = 'erzincan' limit 1),
    null,
    'Kemah Kalesi',
    'kemah-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(39.038102 39.6043679)'::geography,
    'Kemah Kalesi, Erzincan tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','erzincan']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:50:06.833Z'::timestamptz,
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
    (select id from public.provinces where slug = 'erzurum' limit 1),
    null,
    'Palandoken',
    'palandoken',
    'historical'::public.place_category,
    'SRID=4326;POINT(41.1714826 39.9318929)'::geography,
    'Palandoken, Erzurum tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','erzurum']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:50:10.031Z'::timestamptz,
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
    (select id from public.provinces where slug = 'erzurum' limit 1),
    null,
    'Cifte Minareli Medrese',
    'cifte-minareli-medrese',
    'historical'::public.place_category,
    'SRID=4326;POINT(41.2782428 39.9056302)'::geography,
    'Cifte Minareli Medrese, Erzurum tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','erzurum']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:50:11.801Z'::timestamptz,
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
    (select id from public.provinces where slug = 'erzurum' limit 1),
    null,
    'Tortum Selalesi',
    'tortum-selalesi',
    'nature'::public.place_category,
    'SRID=4326;POINT(41.6684361 40.6609123)'::geography,
    'Tortum Selalesi, Erzurum bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','erzurum']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:50:14.096Z'::timestamptz,
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
    (select id from public.provinces where slug = 'eskisehir' limit 1),
    null,
    'Odunpazari',
    'odunpazari',
    'historical'::public.place_category,
    'SRID=4326;POINT(30.5237649 39.7655536)'::geography,
    'Odunpazari, Eskişehir tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','eskişehir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:50:15.794Z'::timestamptz,
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
    (select id from public.provinces where slug = 'eskisehir' limit 1),
    null,
    'Sazova',
    'sazova',
    'historical'::public.place_category,
    'SRID=4326;POINT(30.4677892 39.7665299)'::geography,
    'Sazova, Eskişehir tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','eskişehir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:50:17.924Z'::timestamptz,
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
    (select id from public.provinces where slug = 'eskisehir' limit 1),
    null,
    'Porsuk Cayi',
    'porsuk-cayi',
    'historical'::public.place_category,
    'SRID=4326;POINT(30.6481587 39.7612114)'::geography,
    'Porsuk Cayi, Eskişehir tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','eskişehir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:50:19.598Z'::timestamptz,
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
    (select id from public.provinces where slug = 'gaziantep' limit 1),
    null,
    'Zeugma',
    'zeugma',
    'historical'::public.place_category,
    'SRID=4326;POINT(37.8706039 37.0573936)'::geography,
    'Zeugma, Gaziantep tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','gaziantep']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:50:21.592Z'::timestamptz,
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
    (select id from public.provinces where slug = 'gaziantep' limit 1),
    null,
    'Gaziantep Kalesi',
    'gaziantep-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(37.3832064 37.0664591)'::geography,
    'Gaziantep Kalesi, Gaziantep tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','gaziantep']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:50:23.432Z'::timestamptz,
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
    (select id from public.provinces where slug = 'gaziantep' limit 1),
    null,
    'Bakircilar Carsisi',
    'bakircilar-carsisi',
    'historical'::public.place_category,
    'SRID=4326;POINT(37.3864207 37.0622505)'::geography,
    'Bakircilar Carsisi, Gaziantep tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','gaziantep']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:50:25.259Z'::timestamptz,
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
    (select id from public.provinces where slug = 'giresun' limit 1),
    null,
    'Giresun Adasi',
    'giresun-adasi',
    'beach'::public.place_category,
    'SRID=4326;POINT(38.4365584 40.9293597)'::geography,
    'Giresun Adasi, Giresun tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','giresun']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:50:27.163Z'::timestamptz,
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
    (select id from public.provinces where slug = 'giresun' limit 1),
    null,
    'Kulakkaya',
    'kulakkaya',
    'historical'::public.place_category,
    'SRID=4326;POINT(38.350452 40.6592364)'::geography,
    'Kulakkaya, Giresun tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','giresun']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:50:30.408Z'::timestamptz,
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
    (select id from public.provinces where slug = 'gumushane' limit 1),
    null,
    'Karaca Magarasi',
    'karaca-magarasi',
    'nature'::public.place_category,
    'SRID=4326;POINT(39.4028933 40.5442916)'::geography,
    'Karaca Magarasi, Gümüşhane bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','gümüşhane']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:50:32.215Z'::timestamptz,
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
    (select id from public.provinces where slug = 'hatay' limit 1),
    null,
    'St Pierre',
    'st-pierre',
    'historical'::public.place_category,
    'SRID=4326;POINT(36.1782424 36.2093782)'::geography,
    'St Pierre, Hatay tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','hatay']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:50:42.044Z'::timestamptz,
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
    (select id from public.provinces where slug = 'hatay' limit 1),
    null,
    'Harbiye Selalesi',
    'harbiye-selalesi',
    'nature'::public.place_category,
    'SRID=4326;POINT(36.1662266 36.1315794)'::geography,
    'Harbiye Selalesi, Hatay bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','hatay']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:50:43.909Z'::timestamptz,
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
    (select id from public.provinces where slug = 'hatay' limit 1),
    null,
    'Uzun Carsi',
    'uzun-carsi',
    'historical'::public.place_category,
    'SRID=4326;POINT(36.1628646 36.2027447)'::geography,
    'Uzun Carsi, Hatay tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','hatay']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:50:46.146Z'::timestamptz,
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
    (select id from public.provinces where slug = 'igdir' limit 1),
    null,
    'Tuzluca',
    'tuzluca',
    'historical'::public.place_category,
    'SRID=4326;POINT(43.6637878 40.0402158)'::geography,
    'Tuzluca, Iğdır tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','iğdır']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:50:49.238Z'::timestamptz,
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
    (select id from public.provinces where slug = 'isparta' limit 1),
    null,
    'Egirdir Golu',
    'egirdir-golu',
    'nature'::public.place_category,
    'SRID=4326;POINT(30.8944037 38.059202)'::geography,
    'Egirdir Golu, Isparta bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','isparta']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:50:51.033Z'::timestamptz,
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
    (select id from public.provinces where slug = 'isparta' limit 1),
    null,
    'Lavanta',
    'lavanta',
    'historical'::public.place_category,
    'SRID=4326;POINT(30.5211346 37.7772051)'::geography,
    'Lavanta, Isparta tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','isparta']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:50:53.370Z'::timestamptz,
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
    (select id from public.provinces where slug = 'isparta' limit 1),
    null,
    'Kovada Golu',
    'kovada-golu',
    'beach'::public.place_category,
    'SRID=4326;POINT(30.8818629 37.6339428)'::geography,
    'Kovada Golu, Isparta tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','isparta']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:50:55.163Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    null,
    'Kiz Kulesi',
    'kiz-kulesi',
    'viewpoint'::public.place_category,
    'SRID=4326;POINT(29.0041322 41.0210488)'::geography,
    'Kiz Kulesi, İstanbul civarinda manzara ve fotograf icin one cikan ikonik bir noktadir.',
    'sunset'::public.best_time,
    60,
    array['must-see','iconic','i̇stanbul']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:50:56.964Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    null,
    'Galata Kulesi',
    'galata-kulesi',
    'viewpoint'::public.place_category,
    'SRID=4326;POINT(28.9742134 41.0256406)'::geography,
    'Galata Kulesi, İstanbul civarinda manzara ve fotograf icin one cikan ikonik bir noktadir.',
    'sunset'::public.best_time,
    60,
    array['must-see','iconic','i̇stanbul']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:50:58.633Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    null,
    'Ayasofya',
    'ayasofya',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.9800112 41.0085046)'::geography,
    'Ayasofya, İstanbul tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:51:00.383Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    null,
    'Topkapi Sarayi',
    'topkapi-sarayi',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.9840659 41.0129795)'::geography,
    'Topkapi Sarayi, İstanbul tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:51:02.296Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    null,
    'Sultanahmet',
    'sultanahmet',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.9769087 41.0041141)'::geography,
    'Sultanahmet, İstanbul tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:51:03.986Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    null,
    'Adalar',
    'adalar',
    'beach'::public.place_category,
    'SRID=4326;POINT(29.1293251 40.8741659)'::geography,
    'Adalar, İstanbul tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','i̇stanbul']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:51:05.808Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    null,
    'Buyukada',
    'buyukada',
    'beach'::public.place_category,
    'SRID=4326;POINT(29.1190366 40.8563545)'::geography,
    'Buyukada, İstanbul tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','i̇stanbul']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:51:07.537Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    null,
    'Kapali Carsi',
    'kapali-carsi',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.9680224 41.0109541)'::geography,
    'Kapali Carsi, İstanbul tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:51:09.739Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    null,
    'Misir Carsisi',
    'misir-carsisi',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.9705376 41.0164786)'::geography,
    'Misir Carsisi, İstanbul tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:51:11.351Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    null,
    'Yerebatan Sarnici',
    'yerebatan-sarnici',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.9783826 41.0084795)'::geography,
    'Yerebatan Sarnici, İstanbul tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:51:13.031Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    null,
    'Suleymaniye Camii',
    'suleymaniye-camii',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.9639548 41.0162287)'::geography,
    'Suleymaniye Camii, İstanbul tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:51:14.976Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    null,
    'Dolmabahce Sarayi',
    'dolmabahce-sarayi',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.9997735 41.0389605)'::geography,
    'Dolmabahce Sarayi, İstanbul tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:51:16.637Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    null,
    'Fener Balat',
    'fener-balat',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.9509216 41.0298173)'::geography,
    'Fener Balat, İstanbul tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:51:18.709Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    null,
    'Dolmabahce',
    'dolmabahce',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.9997735 41.0389605)'::geography,
    'Dolmabahce, İstanbul tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:51:20.508Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    null,
    'Rumeli Hisari',
    'rumeli-hisari',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.0567125 41.0849171)'::geography,
    'Rumeli Hisari, İstanbul tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:51:22.711Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    null,
    'Eyup Sultan Camii',
    'eyup-sultan-camii',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.9337456 41.0480113)'::geography,
    'Eyup Sultan Camii, İstanbul tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:51:24.485Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    null,
    'Kadikoy',
    'kadikoy',
    'beach'::public.place_category,
    'SRID=4326;POINT(29.0245631 40.9912955)'::geography,
    'Kadikoy, İstanbul tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','i̇stanbul']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:51:26.179Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    null,
    'Ortakoy',
    'ortakoy',
    'beach'::public.place_category,
    'SRID=4326;POINT(29.0281901 41.0546272)'::geography,
    'Ortakoy, İstanbul tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','i̇stanbul']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:51:27.959Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    null,
    'Efes',
    'efes',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.3393194 37.9404456)'::geography,
    'Efes, İzmir tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:51:30.151Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    null,
    'Saat Kulesi',
    'saat-kulesi',
    'viewpoint'::public.place_category,
    'SRID=4326;POINT(27.3691 37.9484602)'::geography,
    'Saat Kulesi, İzmir civarinda manzara ve fotograf icin one cikan ikonik bir noktadir.',
    'sunset'::public.best_time,
    60,
    array['must-see','iconic','i̇zmir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:51:32.299Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    null,
    'Sirince',
    'sirince',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.4328343 37.9423518)'::geography,
    'Sirince, İzmir tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:51:33.939Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    null,
    'Kordon',
    'kordon',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.1376895 38.4328514)'::geography,
    'Kordon, İzmir tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:51:35.762Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    null,
    'Alacati',
    'alacati',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.3745176 38.2847573)'::geography,
    'Alacati, İzmir tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:51:38.164Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    null,
    'Asklepion',
    'asklepion',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.1656658 39.1189248)'::geography,
    'Asklepion, İzmir tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:51:41.903Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    null,
    'Birgi',
    'birgi',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.0654953 38.2541385)'::geography,
    'Birgi, İzmir tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:51:44.077Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    null,
    'Cesme Kalesi',
    'cesme-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.3039793 38.323578)'::geography,
    'Cesme Kalesi, İzmir tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:51:45.735Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    null,
    'Foca',
    'foca',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.7547749 38.668916)'::geography,
    'Foca, İzmir tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:51:48.069Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    null,
    'Sigacik',
    'sigacik',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.7844611 38.1945123)'::geography,
    'Sigacik, İzmir tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:51:49.759Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    null,
    'Teos',
    'teos',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.7830734 38.1797407)'::geography,
    'Teos, İzmir tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:51:54.298Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    null,
    'Kemeralti',
    'kemeralti',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.1326935 38.4191798)'::geography,
    'Kemeralti, İzmir tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:51:56.043Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    null,
    'Asansor',
    'asansor',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.117476 38.4087859)'::geography,
    'Asansor, İzmir tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:51:59.284Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    null,
    'Claros',
    'claros',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.1930661 38.0516322)'::geography,
    'Claros, İzmir tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:52:01.988Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    null,
    'Eski Foca',
    'eski-foca',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.7547749 38.668916)'::geography,
    'Eski Foca, İzmir tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:52:04.319Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    null,
    'Urla',
    'urla',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.7672998 38.3228184)'::geography,
    'Urla, İzmir tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:52:05.968Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    null,
    'Odemis',
    'odemis',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.965566 38.2220533)'::geography,
    'Odemis, İzmir tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:52:07.890Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kahramanmaras' limit 1),
    null,
    'Ali Kayasi',
    'ali-kayasi',
    'historical'::public.place_category,
    'SRID=4326;POINT(36.791017 37.7451361)'::geography,
    'Ali Kayasi, Kahramanmaraş tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','kahramanmaraş']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:52:11.041Z'::timestamptz,
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
    (select id from public.provinces where slug = 'karabuk' limit 1),
    null,
    'Safranbolu',
    'safranbolu',
    'historical'::public.place_category,
    'SRID=4326;POINT(32.6929575 41.2456658)'::geography,
    'Safranbolu, Karabük tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','karabük']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:52:12.764Z'::timestamptz,
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
    (select id from public.provinces where slug = 'karabuk' limit 1),
    null,
    'Tokatli Kanyonu',
    'tokatli-kanyonu',
    'nature'::public.place_category,
    'SRID=4326;POINT(32.6864007 41.2738398)'::geography,
    'Tokatli Kanyonu, Karabük bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','karabük']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:52:14.492Z'::timestamptz,
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
    (select id from public.provinces where slug = 'karaman' limit 1),
    null,
    'Binbir Kilise',
    'binbir-kilise',
    'historical'::public.place_category,
    'SRID=4326;POINT(33.1174894 37.431542)'::geography,
    'Binbir Kilise, Karaman tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','karaman']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:52:19.815Z'::timestamptz,
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
    (select id from public.provinces where slug = 'karaman' limit 1),
    null,
    'Karaman Kalesi',
    'karaman-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(33.2064648 37.1820307)'::geography,
    'Karaman Kalesi, Karaman tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','karaman']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:52:21.667Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kars' limit 1),
    null,
    'Cildir Golu',
    'cildir-golu',
    'nature'::public.place_category,
    'SRID=4326;POINT(43.2636391 41.0193871)'::geography,
    'Cildir Golu, Kars bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','kars']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:52:25.350Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kars' limit 1),
    null,
    'Kars Kalesi',
    'kars-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(43.0899656 40.6134666)'::geography,
    'Kars Kalesi, Kars tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','kars']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:52:27.227Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kastamonu' limit 1),
    null,
    'Ilgaz',
    'ilgaz',
    'historical'::public.place_category,
    'SRID=4326;POINT(33.7367784 41.068265)'::geography,
    'Ilgaz, Kastamonu tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','kastamonu']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:52:29.172Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kastamonu' limit 1),
    null,
    'Valla Kanyonu',
    'valla-kanyonu',
    'nature'::public.place_category,
    'SRID=4326;POINT(33.0451819 41.7490085)'::geography,
    'Valla Kanyonu, Kastamonu bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','kastamonu']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:52:30.874Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kastamonu' limit 1),
    null,
    'Kastamonu Kalesi',
    'kastamonu-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(33.76968 41.3747689)'::geography,
    'Kastamonu Kalesi, Kastamonu tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','kastamonu']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:52:32.825Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kayseri' limit 1),
    null,
    'Erciyes',
    'erciyes',
    'historical'::public.place_category,
    'SRID=4326;POINT(35.4502248 38.5327397)'::geography,
    'Erciyes, Kayseri tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','kayseri']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:52:34.819Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kayseri' limit 1),
    null,
    'Hunat Hatun',
    'hunat-hatun',
    'historical'::public.place_category,
    'SRID=4326;POINT(35.4917518 38.7204122)'::geography,
    'Hunat Hatun, Kayseri tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','kayseri']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:52:36.679Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kilis' limit 1),
    null,
    'Ravanda Kalesi',
    'ravanda-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(37.0538644 36.8730683)'::geography,
    'Ravanda Kalesi, Kilis tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','kilis']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:52:40.041Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kirikkale' limit 1),
    null,
    'Keskin',
    'keskin',
    'historical'::public.place_category,
    'SRID=4326;POINT(33.615167 39.673994)'::geography,
    'Keskin, Kırıkkale tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','kırıkkale']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:52:43.209Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kirikkale' limit 1),
    null,
    'Silah Sanayi Muzesi',
    'silah-sanayi-muzesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(33.5153435 39.846857)'::geography,
    'Silah Sanayi Muzesi, Kırıkkale tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','kırıkkale']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:52:45.060Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kirklareli' limit 1),
    null,
    'Igneada',
    'igneada',
    'beach'::public.place_category,
    'SRID=4326;POINT(27.9628493 41.8883302)'::geography,
    'Igneada, Kırklareli tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','kırklareli']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:52:46.729Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kirklareli' limit 1),
    null,
    'Dupnisa Magarasi',
    'dupnisa-magarasi',
    'nature'::public.place_category,
    'SRID=4326;POINT(27.5558656 41.8405795)'::geography,
    'Dupnisa Magarasi, Kırklareli bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','kırklareli']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:52:48.449Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kirklareli' limit 1),
    null,
    'Longoz Ormanlari',
    'longoz-ormanlari',
    'nature'::public.place_category,
    'SRID=4326;POINT(27.9565008 41.8233204)'::geography,
    'Longoz Ormanlari, Kırklareli bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','kırklareli']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:52:50.744Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kirsehir' limit 1),
    null,
    'Seyfe Golu',
    'seyfe-golu',
    'nature'::public.place_category,
    'SRID=4326;POINT(34.3882869 39.214861)'::geography,
    'Seyfe Golu, Kırşehir bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','kırşehir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:52:52.527Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kirsehir' limit 1),
    null,
    'Cacabey Medresesi',
    'cacabey-medresesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.1614742 39.1451338)'::geography,
    'Cacabey Medresesi, Kırşehir tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','kırşehir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:52:56.403Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kocaeli' limit 1),
    null,
    'Ormanya',
    'ormanya',
    'nature'::public.place_category,
    'SRID=4326;POINT(30.1625104 40.7328027)'::geography,
    'Ormanya, Kocaeli bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','kocaeli']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:52:58.229Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kocaeli' limit 1),
    null,
    'Kartepe',
    'kartepe',
    'viewpoint'::public.place_category,
    'SRID=4326;POINT(30.0112827 40.7454357)'::geography,
    'Kartepe, Kocaeli civarinda manzara ve fotograf icin one cikan ikonik bir noktadir.',
    'sunset'::public.best_time,
    60,
    array['must-see','iconic','kocaeli']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:53:00.674Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kocaeli' limit 1),
    null,
    'Sekapark',
    'sekapark',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.910907 40.76138)'::geography,
    'Sekapark, Kocaeli tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','kocaeli']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:53:02.535Z'::timestamptz,
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
    (select id from public.provinces where slug = 'konya' limit 1),
    null,
    'Sille',
    'sille',
    'historical'::public.place_category,
    'SRID=4326;POINT(32.4184745 37.9282065)'::geography,
    'Sille, Konya tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','konya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:53:06.694Z'::timestamptz,
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
    (select id from public.provinces where slug = 'konya' limit 1),
    null,
    'Catalhoyuk',
    'catalhoyuk',
    'historical'::public.place_category,
    'SRID=4326;POINT(32.8252568 37.6667937)'::geography,
    'Catalhoyuk, Konya tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','konya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:53:09.010Z'::timestamptz,
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
    (select id from public.provinces where slug = 'konya' limit 1),
    null,
    'Tuz Golu',
    'tuz-golu',
    'nature'::public.place_category,
    'SRID=4326;POINT(33.2915362 38.8594356)'::geography,
    'Tuz Golu, Konya bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','konya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:53:10.648Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kutahya' limit 1),
    null,
    'Aizanoi',
    'aizanoi',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.6096562 39.2011197)'::geography,
    'Aizanoi, Kütahya tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','kütahya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:53:12.337Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kutahya' limit 1),
    null,
    'Frig Vadisi',
    'frig-vadisi',
    'nature'::public.place_category,
    'SRID=4326;POINT(30.1244608 39.5840167)'::geography,
    'Frig Vadisi, Kütahya bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','kütahya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:53:14.092Z'::timestamptz,
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
    (select id from public.provinces where slug = 'malatya' limit 1),
    null,
    'Arslantepe',
    'arslantepe',
    'viewpoint'::public.place_category,
    'SRID=4326;POINT(38.3607149 38.3815255)'::geography,
    'Arslantepe, Malatya civarinda manzara ve fotograf icin one cikan ikonik bir noktadir.',
    'sunset'::public.best_time,
    60,
    array['must-see','iconic','malatya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:53:17.505Z'::timestamptz,
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
    (select id from public.provinces where slug = 'malatya' limit 1),
    null,
    'Gunduzbey',
    'gunduzbey',
    'historical'::public.place_category,
    'SRID=4326;POINT(38.2619215 38.2825471)'::geography,
    'Gunduzbey, Malatya tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','malatya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:53:19.953Z'::timestamptz,
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
    (select id from public.provinces where slug = 'malatya' limit 1),
    null,
    'Levent Vadisi',
    'levent-vadisi',
    'nature'::public.place_category,
    'SRID=4326;POINT(37.9241206 38.4084006)'::geography,
    'Levent Vadisi, Malatya bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','malatya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:53:21.835Z'::timestamptz,
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
    (select id from public.provinces where slug = 'manisa' limit 1),
    null,
    'Spil Dagi',
    'spil-dagi',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.4548431 38.566982)'::geography,
    'Spil Dagi, Manisa tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','manisa']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:53:24.072Z'::timestamptz,
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
    (select id from public.provinces where slug = 'manisa' limit 1),
    null,
    'Aglayan Kaya',
    'aglayan-kaya',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.424058 38.6053511)'::geography,
    'Aglayan Kaya, Manisa tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','manisa']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:53:27.764Z'::timestamptz,
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
    (select id from public.provinces where slug = 'mardin' limit 1),
    null,
    'Dara Antik Kenti',
    'dara-antik-kenti',
    'historical'::public.place_category,
    'SRID=4326;POINT(40.945756 37.17899)'::geography,
    'Dara Antik Kenti, Mardin tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','mardin']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:53:31.523Z'::timestamptz,
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
    (select id from public.provinces where slug = 'mersin' limit 1),
    null,
    'Kizkalesi',
    'kizkalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.1484522 36.4567784)'::geography,
    'Kizkalesi, Mersin tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','mersin']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:53:35.669Z'::timestamptz,
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
    (select id from public.provinces where slug = 'mersin' limit 1),
    null,
    'Tarsus Selalesi',
    'tarsus-selalesi',
    'nature'::public.place_category,
    'SRID=4326;POINT(34.898408 36.9333126)'::geography,
    'Tarsus Selalesi, Mersin bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','mersin']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:53:39.090Z'::timestamptz,
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
    '2026-09-11T11:53:40.831Z'::timestamptz,
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
    'historical'::public.place_category,
    'SRID=4326;POINT(29.0874591 36.5781319)'::geography,
    'Kayakoy, Muğla tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:53:42.760Z'::timestamptz,
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
    'nature'::public.place_category,
    'SRID=4326;POINT(29.3748882 36.6084603)'::geography,
    'Saklikent, Muğla bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','muğla']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:53:46.155Z'::timestamptz,
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
    '2026-09-11T11:53:47.804Z'::timestamptz,
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
    '2026-09-11T11:53:49.518Z'::timestamptz,
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
    '2026-09-11T11:53:51.385Z'::timestamptz,
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
    '2026-09-11T11:53:53.224Z'::timestamptz,
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
    'nature'::public.place_category,
    'SRID=4326;POINT(28.2368886 36.7159589)'::geography,
    'Azmak, Muğla bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','muğla']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:53:55.001Z'::timestamptz,
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
    '2026-09-11T11:53:57.210Z'::timestamptz,
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
    '2026-09-11T11:53:59.097Z'::timestamptz,
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
    '2026-09-11T11:54:00.922Z'::timestamptz,
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
    'Sedir Adasi',
    'sedir-adasi',
    'beach'::public.place_category,
    'SRID=4326;POINT(28.2021898 36.9933237)'::geography,
    'Sedir Adasi, Muğla tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','muğla']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:54:02.732Z'::timestamptz,
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
    'Akyaka',
    'akyaka',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.3271055 37.0580313)'::geography,
    'Akyaka, Muğla tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:54:04.627Z'::timestamptz,
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
    'Marmaris',
    'marmaris',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.2742661 36.8522547)'::geography,
    'Marmaris, Muğla tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:54:06.471Z'::timestamptz,
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
    'Bozburun',
    'bozburun',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.0442768 36.6927783)'::geography,
    'Bozburun, Muğla tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:54:08.267Z'::timestamptz,
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
    'Koycegiz Golu',
    'koycegiz-golu',
    'beach'::public.place_category,
    'SRID=4326;POINT(28.6542344 36.9061963)'::geography,
    'Koycegiz Golu, Muğla tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','muğla']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:54:10.082Z'::timestamptz,
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
    'Letoon',
    'letoon',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.2895657 36.3315757)'::geography,
    'Letoon, Muğla tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:54:11.835Z'::timestamptz,
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
    'Gumusluk',
    'gumusluk',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.2366323 37.0535073)'::geography,
    'Gumusluk, Muğla tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:54:15.592Z'::timestamptz,
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
    'Stratonikeia',
    'stratonikeia',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.0653697 37.3128877)'::geography,
    'Stratonikeia, Muğla tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:54:17.376Z'::timestamptz,
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
    'Dalyan',
    'dalyan',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.6423915 36.8350176)'::geography,
    'Dalyan, Muğla tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:54:20.344Z'::timestamptz,
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
    'Turunc',
    'turunc',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.2467298 36.7728847)'::geography,
    'Turunc, Muğla tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:54:22.289Z'::timestamptz,
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
    (select id from public.provinces where slug = 'mus' limit 1),
    null,
    'Malazgirt',
    'malazgirt',
    'historical'::public.place_category,
    'SRID=4326;POINT(42.5409459 39.1461406)'::geography,
    'Malazgirt, Muş tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muş']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:54:25.334Z'::timestamptz,
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
    (select id from public.provinces where slug = 'nevsehir' limit 1),
    null,
    'Goreme',
    'goreme',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.8296234 38.642089)'::geography,
    'Goreme, Nevşehir tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','nevşehir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:54:28.606Z'::timestamptz,
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
    (select id from public.provinces where slug = 'nevsehir' limit 1),
    null,
    'Uchisar',
    'uchisar',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.8046138 38.6293826)'::geography,
    'Uchisar, Nevşehir tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','nevşehir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:54:30.313Z'::timestamptz,
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
    (select id from public.provinces where slug = 'nevsehir' limit 1),
    null,
    'Derinkuyu',
    'derinkuyu',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.6995885 38.4003089)'::geography,
    'Derinkuyu, Nevşehir tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','nevşehir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:54:32.052Z'::timestamptz,
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
    (select id from public.provinces where slug = 'nevsehir' limit 1),
    null,
    'Kaymakli',
    'kaymakli',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.7508835 38.4608115)'::geography,
    'Kaymakli, Nevşehir tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','nevşehir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:54:33.943Z'::timestamptz,
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
    (select id from public.provinces where slug = 'nevsehir' limit 1),
    null,
    'Avanos',
    'avanos',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.8536656 38.8709056)'::geography,
    'Avanos, Nevşehir tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','nevşehir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:54:38.765Z'::timestamptz,
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
    (select id from public.provinces where slug = 'nevsehir' limit 1),
    null,
    'Urgup',
    'urgup',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.9594552 38.5928119)'::geography,
    'Urgup, Nevşehir tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','nevşehir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:54:40.718Z'::timestamptz,
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
    (select id from public.provinces where slug = 'nevsehir' limit 1),
    null,
    'Kapadokya',
    'kapadokya',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.8455184 38.6386124)'::geography,
    'Kapadokya, Nevşehir tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','nevşehir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:54:42.827Z'::timestamptz,
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
    (select id from public.provinces where slug = 'nevsehir' limit 1),
    null,
    'Goreme Acik Hava Muzesi',
    'goreme-acik-hava-muzesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.8451355 38.6396419)'::geography,
    'Goreme Acik Hava Muzesi, Nevşehir tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','nevşehir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:54:44.632Z'::timestamptz,
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
    (select id from public.provinces where slug = 'nevsehir' limit 1),
    null,
    'Uc Guzeller',
    'uc-guzeller',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.8903599 38.6354696)'::geography,
    'Uc Guzeller, Nevşehir tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','nevşehir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:54:46.500Z'::timestamptz,
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
    (select id from public.provinces where slug = 'nevsehir' limit 1),
    null,
    'Guvercinlik Vadisi',
    'guvercinlik-vadisi',
    'nature'::public.place_category,
    'SRID=4326;POINT(34.8130694 38.630378)'::geography,
    'Guvercinlik Vadisi, Nevşehir bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','nevşehir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:54:48.143Z'::timestamptz,
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
    (select id from public.provinces where slug = 'nevsehir' limit 1),
    null,
    'Hacibektas',
    'hacibektas',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.5608817 38.9428835)'::geography,
    'Hacibektas, Nevşehir tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','nevşehir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:54:51.464Z'::timestamptz,
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
    (select id from public.provinces where slug = 'nigde' limit 1),
    null,
    'Aladaglar',
    'aladaglar',
    'beach'::public.place_category,
    'SRID=4326;POINT(35.151394 37.836758)'::geography,
    'Aladaglar, Niğde tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','niğde']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:54:57.047Z'::timestamptz,
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
    (select id from public.provinces where slug = 'nigde' limit 1),
    null,
    'Gumusler Manastiri',
    'gumusler-manastiri',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.7722157 37.9979388)'::geography,
    'Gumusler Manastiri, Niğde tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','niğde']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:54:58.779Z'::timestamptz,
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
    (select id from public.provinces where slug = 'ordu' limit 1),
    null,
    'Boztepe',
    'boztepe',
    'viewpoint'::public.place_category,
    'SRID=4326;POINT(37.8388613 40.9998082)'::geography,
    'Boztepe, Ordu civarinda manzara ve fotograf icin one cikan ikonik bir noktadir.',
    'sunset'::public.best_time,
    60,
    array['must-see','iconic','ordu']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:55:02.559Z'::timestamptz,
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
    (select id from public.provinces where slug = 'ordu' limit 1),
    null,
    'Yason Burnu',
    'yason-burnu',
    'historical'::public.place_category,
    'SRID=4326;POINT(37.6829645 41.1364025)'::geography,
    'Yason Burnu, Ordu tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','ordu']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:55:05.299Z'::timestamptz,
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
    (select id from public.provinces where slug = 'ordu' limit 1),
    null,
    'Ulugol',
    'ulugol',
    'nature'::public.place_category,
    'SRID=4326;POINT(37.5457645 40.6302479)'::geography,
    'Ulugol, Ordu bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','ordu']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:55:07.174Z'::timestamptz,
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
    (select id from public.provinces where slug = 'osmaniye' limit 1),
    null,
    'Kastabala',
    'kastabala',
    'historical'::public.place_category,
    'SRID=4326;POINT(36.1892507 37.176627)'::geography,
    'Kastabala, Osmaniye tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','osmaniye']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:55:09.663Z'::timestamptz,
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
    (select id from public.provinces where slug = 'osmaniye' limit 1),
    null,
    'Karatepe Aslantas',
    'karatepe-aslantas',
    'viewpoint'::public.place_category,
    'SRID=4326;POINT(36.2266102 37.2731757)'::geography,
    'Karatepe Aslantas, Osmaniye civarinda manzara ve fotograf icin one cikan ikonik bir noktadir.',
    'sunset'::public.best_time,
    60,
    array['must-see','iconic','osmaniye']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:55:11.431Z'::timestamptz,
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
    (select id from public.provinces where slug = 'osmaniye' limit 1),
    null,
    'Toprakkale',
    'toprakkale',
    'historical'::public.place_category,
    'SRID=4326;POINT(36.1455025 37.0666092)'::geography,
    'Toprakkale, Osmaniye tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','osmaniye']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:55:14.139Z'::timestamptz,
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
    (select id from public.provinces where slug = 'rize' limit 1),
    null,
    'Ayder',
    'ayder',
    'historical'::public.place_category,
    'SRID=4326;POINT(41.1020508 40.9525203)'::geography,
    'Ayder, Rize tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','rize']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:55:16.435Z'::timestamptz,
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
    (select id from public.provinces where slug = 'rize' limit 1),
    null,
    'Zilkale',
    'zilkale',
    'historical'::public.place_category,
    'SRID=4326;POINT(40.9632024 40.9593912)'::geography,
    'Zilkale, Rize tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','rize']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:55:18.589Z'::timestamptz,
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
    (select id from public.provinces where slug = 'rize' limit 1),
    null,
    'Pokut',
    'pokut',
    'historical'::public.place_category,
    'SRID=4326;POINT(41.0288257 40.9633768)'::geography,
    'Pokut, Rize tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','rize']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:55:20.479Z'::timestamptz,
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
    (select id from public.provinces where slug = 'rize' limit 1),
    null,
    'Firtina Deresi',
    'firtina-deresi',
    'historical'::public.place_category,
    'SRID=4326;POINT(41.0096629 41.0679951)'::geography,
    'Firtina Deresi, Rize tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','rize']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:55:22.282Z'::timestamptz,
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
    (select id from public.provinces where slug = 'sakarya' limit 1),
    null,
    'Sapanca Golu',
    'sapanca-golu',
    'nature'::public.place_category,
    'SRID=4326;POINT(30.2420272 40.7172304)'::geography,
    'Sapanca Golu, Sakarya bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','sakarya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:55:24.081Z'::timestamptz,
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
    (select id from public.provinces where slug = 'sakarya' limit 1),
    null,
    'Acarlar Longozu',
    'acarlar-longozu',
    'historical'::public.place_category,
    'SRID=4326;POINT(30.4925257 41.1223944)'::geography,
    'Acarlar Longozu, Sakarya tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','sakarya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:55:25.719Z'::timestamptz,
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
    (select id from public.provinces where slug = 'sakarya' limit 1),
    null,
    'Maden Deresi',
    'maden-deresi',
    'historical'::public.place_category,
    'SRID=4326;POINT(30.788077 41.053342)'::geography,
    'Maden Deresi, Sakarya tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','sakarya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:55:27.450Z'::timestamptz,
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
    (select id from public.provinces where slug = 'samsun' limit 1),
    null,
    'Sahinkaya Kanyonu',
    'sahinkaya-kanyonu',
    'nature'::public.place_category,
    'SRID=4326;POINT(35.4057125 41.2707932)'::geography,
    'Sahinkaya Kanyonu, Samsun bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','samsun']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:55:32.576Z'::timestamptz,
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
    (select id from public.provinces where slug = 'sanliurfa' limit 1),
    null,
    'Gobeklitepe',
    'gobeklitepe',
    'viewpoint'::public.place_category,
    'SRID=4326;POINT(38.9206472 37.2233511)'::geography,
    'Gobeklitepe, Şanlıurfa civarinda manzara ve fotograf icin one cikan ikonik bir noktadir.',
    'sunset'::public.best_time,
    60,
    array['must-see','iconic','şanlıurfa']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:55:34.374Z'::timestamptz,
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
    (select id from public.provinces where slug = 'sanliurfa' limit 1),
    null,
    'Harran',
    'harran',
    'historical'::public.place_category,
    'SRID=4326;POINT(39.0251364 36.8710059)'::geography,
    'Harran, Şanlıurfa tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','şanlıurfa']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:55:38.625Z'::timestamptz,
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
    (select id from public.provinces where slug = 'siirt' limit 1),
    null,
    'Tillo',
    'tillo',
    'historical'::public.place_category,
    'SRID=4326;POINT(42.0125174 37.9500638)'::geography,
    'Tillo, Siirt tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','siirt']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:55:40.296Z'::timestamptz,
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
    (select id from public.provinces where slug = 'siirt' limit 1),
    null,
    'Botan Vadisi',
    'botan-vadisi',
    'nature'::public.place_category,
    'SRID=4326;POINT(41.9422506 37.89351)'::geography,
    'Botan Vadisi, Siirt bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','siirt']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:55:41.993Z'::timestamptz,
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
    (select id from public.provinces where slug = 'siirt' limit 1),
    null,
    'Veysel Karani',
    'veysel-karani',
    'historical'::public.place_category,
    'SRID=4326;POINT(41.7145609 38.1317002)'::geography,
    'Veysel Karani, Siirt tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','siirt']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:55:44.231Z'::timestamptz,
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
    (select id from public.provinces where slug = 'sinop' limit 1),
    null,
    'Sinop Cezaevi',
    'sinop-cezaevi',
    'historical'::public.place_category,
    'SRID=4326;POINT(35.1424343 42.0246097)'::geography,
    'Sinop Cezaevi, Sinop tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','sinop']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:55:46.090Z'::timestamptz,
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
    (select id from public.provinces where slug = 'sinop' limit 1),
    null,
    'Hamsilos',
    'hamsilos',
    'historical'::public.place_category,
    'SRID=4326;POINT(35.0435651 42.0638912)'::geography,
    'Hamsilos, Sinop tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','sinop']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:55:48.205Z'::timestamptz,
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
    (select id from public.provinces where slug = 'sinop' limit 1),
    null,
    'Inceburun',
    'inceburun',
    'historical'::public.place_category,
    'SRID=4326;POINT(35.0434855 42.0412483)'::geography,
    'Inceburun, Sinop tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','sinop']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:55:49.826Z'::timestamptz,
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
    (select id from public.provinces where slug = 'sivas' limit 1),
    null,
    'Divrigi Ulu Cami',
    'divrigi-ulu-cami',
    'historical'::public.place_category,
    'SRID=4326;POINT(38.1219282 39.3713625)'::geography,
    'Divrigi Ulu Cami, Sivas tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','sivas']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:55:51.975Z'::timestamptz,
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
    (select id from public.provinces where slug = 'sivas' limit 1),
    null,
    'Gok Medrese',
    'gok-medrese',
    'historical'::public.place_category,
    'SRID=4326;POINT(37.0168037 39.7443204)'::geography,
    'Gok Medrese, Sivas tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','sivas']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:55:54.196Z'::timestamptz,
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
    (select id from public.provinces where slug = 'sirnak' limit 1),
    null,
    'Cudi Dagi',
    'cudi-dagi',
    'historical'::public.place_category,
    'SRID=4326;POINT(42.4543142 37.377528)'::geography,
    'Cudi Dagi, Şırnak tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','şırnak']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:55:58.049Z'::timestamptz,
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
    (select id from public.provinces where slug = 'sirnak' limit 1),
    null,
    'Kasrik Bogazi',
    'kasrik-bogazi',
    'historical'::public.place_category,
    'SRID=4326;POINT(42.1761932 37.3957254)'::geography,
    'Kasrik Bogazi, Şırnak tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','şırnak']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:55:59.924Z'::timestamptz,
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
    (select id from public.provinces where slug = 'tekirdag' limit 1),
    null,
    'Ucmakdere',
    'ucmakdere',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.3650733 40.7981046)'::geography,
    'Ucmakdere, Tekirdağ tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','tekirdağ']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:56:02.125Z'::timestamptz,
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
    (select id from public.provinces where slug = 'tekirdag' limit 1),
    null,
    'Rakoczi Muzesi',
    'rakoczi-muzesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.5099499 40.9741185)'::geography,
    'Rakoczi Muzesi, Tekirdağ tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','tekirdağ']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:56:03.888Z'::timestamptz,
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
    (select id from public.provinces where slug = 'tekirdag' limit 1),
    null,
    'Sarkoy',
    'sarkoy',
    'beach'::public.place_category,
    'SRID=4326;POINT(27.1121862 40.6148728)'::geography,
    'Sarkoy, Tekirdağ tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','tekirdağ']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:56:05.802Z'::timestamptz,
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
    (select id from public.provinces where slug = 'tokat' limit 1),
    null,
    'Ballica Magarasi',
    'ballica-magarasi',
    'nature'::public.place_category,
    'SRID=4326;POINT(36.3015033 40.2273137)'::geography,
    'Ballica Magarasi, Tokat bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','tokat']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:56:07.957Z'::timestamptz,
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
    (select id from public.provinces where slug = 'tokat' limit 1),
    null,
    'Tokat Kalesi',
    'tokat-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(36.5484865 40.317774)'::geography,
    'Tokat Kalesi, Tokat tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','tokat']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:56:09.737Z'::timestamptz,
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
    (select id from public.provinces where slug = 'tokat' limit 1),
    null,
    'Sulusaray',
    'sulusaray',
    'historical'::public.place_category,
    'SRID=4326;POINT(36.083607 39.9974984)'::geography,
    'Sulusaray, Tokat tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','tokat']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:56:11.497Z'::timestamptz,
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
    (select id from public.provinces where slug = 'trabzon' limit 1),
    null,
    'Sumela',
    'sumela',
    'historical'::public.place_category,
    'SRID=4326;POINT(39.6583668 40.6900948)'::geography,
    'Sumela, Trabzon tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','trabzon']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:56:13.180Z'::timestamptz,
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
    (select id from public.provinces where slug = 'trabzon' limit 1),
    null,
    'Uzungol',
    'uzungol',
    'nature'::public.place_category,
    'SRID=4326;POINT(40.2948099 40.6191264)'::geography,
    'Uzungol, Trabzon bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','trabzon']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:56:15.018Z'::timestamptz,
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
    (select id from public.provinces where slug = 'trabzon' limit 1),
    null,
    'Ataturk Kosku',
    'ataturk-kosku',
    'historical'::public.place_category,
    'SRID=4326;POINT(39.6974593 40.9797848)'::geography,
    'Ataturk Kosku, Trabzon tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','trabzon']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:56:16.762Z'::timestamptz,
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
    (select id from public.provinces where slug = 'tunceli' limit 1),
    null,
    'Munzur Vadisi',
    'munzur-vadisi',
    'nature'::public.place_category,
    'SRID=4326;POINT(39.3609546 39.3053295)'::geography,
    'Munzur Vadisi, Tunceli bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','tunceli']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:56:18.354Z'::timestamptz,
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
    (select id from public.provinces where slug = 'tunceli' limit 1),
    null,
    'Ovacik',
    'ovacik',
    'historical'::public.place_category,
    'SRID=4326;POINT(39.2144472 39.3583833)'::geography,
    'Ovacik, Tunceli tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','tunceli']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:56:20.293Z'::timestamptz,
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
    (select id from public.provinces where slug = 'tunceli' limit 1),
    null,
    'Pertek Kalesi',
    'pertek-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(39.2717809 38.8437598)'::geography,
    'Pertek Kalesi, Tunceli tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','tunceli']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:56:22.072Z'::timestamptz,
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
    (select id from public.provinces where slug = 'usak' limit 1),
    null,
    'Ulubey Kanyonu',
    'ulubey-kanyonu',
    'nature'::public.place_category,
    'SRID=4326;POINT(29.3086837 38.4153674)'::geography,
    'Ulubey Kanyonu, Uşak bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','uşak']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:56:23.717Z'::timestamptz,
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
    (select id from public.provinces where slug = 'usak' limit 1),
    null,
    'Blaundus',
    'blaundus',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.2090778 38.3573574)'::geography,
    'Blaundus, Uşak tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','uşak']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:56:27.407Z'::timestamptz,
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
    (select id from public.provinces where slug = 'van' limit 1),
    null,
    'Van Golu',
    'van-golu',
    'nature'::public.place_category,
    'SRID=4326;POINT(43.3225415 38.4685451)'::geography,
    'Van Golu, Van bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','van']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:56:29.250Z'::timestamptz,
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
    (select id from public.provinces where slug = 'van' limit 1),
    null,
    'Akdamar',
    'akdamar',
    'historical'::public.place_category,
    'SRID=4326;POINT(42.9571723 38.3201916)'::geography,
    'Akdamar, Van tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','van']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:56:30.948Z'::timestamptz,
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
    (select id from public.provinces where slug = 'van' limit 1),
    null,
    'Van Kalesi',
    'van-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(43.3384997 38.5030665)'::geography,
    'Van Kalesi, Van tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','van']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:56:33.040Z'::timestamptz,
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
    (select id from public.provinces where slug = 'van' limit 1),
    null,
    'Muradiye Selalesi',
    'muradiye-selalesi',
    'nature'::public.place_category,
    'SRID=4326;POINT(43.7567753 39.0566497)'::geography,
    'Muradiye Selalesi, Van bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','van']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:56:34.685Z'::timestamptz,
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
    (select id from public.provinces where slug = 'yalova' limit 1),
    null,
    'Termal',
    'termal',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.1742892 40.60618)'::geography,
    'Termal, Yalova tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','yalova']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:56:37.784Z'::timestamptz,
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
    (select id from public.provinces where slug = 'yalova' limit 1),
    null,
    'Yuruyen Kosk',
    'yuruyen-kosk',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.2975257 40.6646307)'::geography,
    'Yuruyen Kosk, Yalova tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','yalova']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:56:39.484Z'::timestamptz,
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
    (select id from public.provinces where slug = 'yozgat' limit 1),
    null,
    'Kazankaya Kanyonu',
    'kazankaya-kanyonu',
    'nature'::public.place_category,
    'SRID=4326;POINT(35.3431331 40.2397297)'::geography,
    'Kazankaya Kanyonu, Yozgat bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','yozgat']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:56:44.137Z'::timestamptz,
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
    (select id from public.provinces where slug = 'zonguldak' limit 1),
    null,
    'Gokgol Magarasi',
    'gokgol-magarasi',
    'nature'::public.place_category,
    'SRID=4326;POINT(31.8329698 41.4406304)'::geography,
    'Gokgol Magarasi, Zonguldak bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','zonguldak']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:56:45.859Z'::timestamptz,
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
    (select id from public.provinces where slug = 'zonguldak' limit 1),
    null,
    'Filyos',
    'filyos',
    'historical'::public.place_category,
    'SRID=4326;POINT(32.0211713 41.55994)'::geography,
    'Filyos, Zonguldak tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','zonguldak']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:56:47.566Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'fatih' limit 1),
    'Ayasofya',
    'ayasofya',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.9800112 41.0085046)'::geography,
    'Ayasofya, Fatih tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul','fatih']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:56:49.171Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'fatih' limit 1),
    'Sultanahmet',
    'sultanahmet',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.9769087 41.0041141)'::geography,
    'Sultanahmet, Fatih tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul','fatih']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:56:50.963Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'fatih' limit 1),
    'Topkapi Sarayi',
    'topkapi-sarayi',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.9840659 41.0129795)'::geography,
    'Topkapi Sarayi, Fatih tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul','fatih']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:56:52.636Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'fatih' limit 1),
    'Yerebatan Sarnici',
    'yerebatan-sarnici',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.9783826 41.0084795)'::geography,
    'Yerebatan Sarnici, Fatih tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul','fatih']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:56:54.955Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'fatih' limit 1),
    'Kapali Carsi',
    'kapali-carsi',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.9680224 41.0109541)'::geography,
    'Kapali Carsi, Fatih tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul','fatih']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:56:57.197Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'fatih' limit 1),
    'Misir Carsisi',
    'misir-carsisi',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.9705376 41.0164786)'::geography,
    'Misir Carsisi, Fatih tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul','fatih']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:56:59.561Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'fatih' limit 1),
    'Suleymaniye Camii',
    'suleymaniye-camii',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.9639548 41.0162287)'::geography,
    'Suleymaniye Camii, Fatih tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul','fatih']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:57:01.347Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'fatih' limit 1),
    'Hipodrom',
    'hipodrom',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.9737864 41.0039246)'::geography,
    'Hipodrom, Fatih tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul','fatih']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:57:03.742Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'fatih' limit 1),
    'Fener',
    'fener',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.9509216 41.0298173)'::geography,
    'Fener, Fatih tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul','fatih']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:57:06.115Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'fatih' limit 1),
    'Balat',
    'balat',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.9482931 41.0320032)'::geography,
    'Balat, Fatih tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul','fatih']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:57:08.477Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'fatih' limit 1),
    'Yerebatan',
    'yerebatan',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.9783826 41.0084795)'::geography,
    'Yerebatan, Fatih tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul','fatih']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:57:10.226Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'beyoglu' limit 1),
    'Galata Kulesi',
    'galata-kulesi',
    'viewpoint'::public.place_category,
    'SRID=4326;POINT(28.9742134 41.0256406)'::geography,
    'Galata Kulesi, Beyoglu civarinda manzara ve fotograf icin one cikan ikonik bir noktadir.',
    'sunset'::public.best_time,
    60,
    array['must-see','iconic','i̇stanbul','beyoglu']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:57:11.863Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'beyoglu' limit 1),
    'Istiklal',
    'istiklal',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.9692374 41.0416191)'::geography,
    'Istiklal, Beyoglu tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul','beyoglu']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:57:13.608Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'beyoglu' limit 1),
    'Pera',
    'pera',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.9760667 41.0336544)'::geography,
    'Pera, Beyoglu tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul','beyoglu']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:57:15.430Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'beyoglu' limit 1),
    'Taksim',
    'taksim',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.985549 41.0380506)'::geography,
    'Taksim, Beyoglu tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul','beyoglu']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:57:17.627Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'beyoglu' limit 1),
    'Karakoy',
    'karakoy',
    'beach'::public.place_category,
    'SRID=4326;POINT(28.9740393 41.0228645)'::geography,
    'Karakoy, Beyoglu tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','i̇stanbul','beyoglu']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:57:19.213Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'beyoglu' limit 1),
    'Cihangir',
    'cihangir',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.9853187 41.0330402)'::geography,
    'Cihangir, Beyoglu tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul','beyoglu']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:57:20.867Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'uskudar' limit 1),
    'Kiz Kulesi',
    'kiz-kulesi',
    'viewpoint'::public.place_category,
    'SRID=4326;POINT(29.0041322 41.0210488)'::geography,
    'Kiz Kulesi, Uskudar civarinda manzara ve fotograf icin one cikan ikonik bir noktadir.',
    'sunset'::public.best_time,
    60,
    array['must-see','iconic','i̇stanbul','uskudar']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:57:22.431Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'uskudar' limit 1),
    'Camlica',
    'camlica',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.070587 41.0345279)'::geography,
    'Camlica, Uskudar tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul','uskudar']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:57:24.182Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'uskudar' limit 1),
    'Beylerbeyi Sarayi',
    'beylerbeyi-sarayi',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.0400359 41.0427184)'::geography,
    'Beylerbeyi Sarayi, Uskudar tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul','uskudar']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:57:26.573Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'uskudar' limit 1),
    'Kuzguncuk',
    'kuzguncuk',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.0360265 41.03216)'::geography,
    'Kuzguncuk, Uskudar tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul','uskudar']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:57:28.336Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'besiktas' limit 1),
    'Dolmabahce',
    'dolmabahce',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.9997735 41.0389605)'::geography,
    'Dolmabahce, Besiktas tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul','besiktas']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:57:30.078Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'besiktas' limit 1),
    'Ortakoy',
    'ortakoy',
    'beach'::public.place_category,
    'SRID=4326;POINT(29.0281901 41.0546272)'::geography,
    'Ortakoy, Besiktas tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','i̇stanbul','besiktas']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:57:31.868Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'besiktas' limit 1),
    'Ciragan Sarayi',
    'ciragan-sarayi',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.0153145 41.0434671)'::geography,
    'Ciragan Sarayi, Besiktas tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul','besiktas']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:57:33.660Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'besiktas' limit 1),
    'Yildiz Parki',
    'yildiz-parki',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.0154226 41.0483019)'::geography,
    'Yildiz Parki, Besiktas tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul','besiktas']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:57:35.504Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'besiktas' limit 1),
    'Bebek',
    'bebek',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.0439589 41.0790159)'::geography,
    'Bebek, Besiktas tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul','besiktas']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:57:37.552Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'adalar' limit 1),
    'Buyukada',
    'buyukada',
    'beach'::public.place_category,
    'SRID=4326;POINT(29.1190366 40.8563545)'::geography,
    'Buyukada, Adalar tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','i̇stanbul','adalar']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:57:39.196Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'adalar' limit 1),
    'Heybeliada',
    'heybeliada',
    'beach'::public.place_category,
    'SRID=4326;POINT(29.0910331 40.8762595)'::geography,
    'Heybeliada, Adalar tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','i̇stanbul','adalar']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:57:40.938Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'adalar' limit 1),
    'Adalar',
    'adalar',
    'beach'::public.place_category,
    'SRID=4326;POINT(29.0693042 40.8810674)'::geography,
    'Adalar, Adalar tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','i̇stanbul','adalar']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:57:42.737Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'adalar' limit 1),
    'Kinaliada',
    'kinaliada',
    'beach'::public.place_category,
    'SRID=4326;POINT(29.0547984 40.9088914)'::geography,
    'Kinaliada, Adalar tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','i̇stanbul','adalar']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:57:45.127Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'sariyer' limit 1),
    'Rumeli Hisari',
    'rumeli-hisari',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.0567125 41.0849171)'::geography,
    'Rumeli Hisari, Sariyer tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul','sariyer']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:57:46.917Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'sariyer' limit 1),
    'Emirgan Korusu',
    'emirgan-korusu',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.0525172 41.1090119)'::geography,
    'Emirgan Korusu, Sariyer tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul','sariyer']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:57:48.678Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'sariyer' limit 1),
    'Tarabya',
    'tarabya',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.0530421 41.1385739)'::geography,
    'Tarabya, Sariyer tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul','sariyer']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:57:50.505Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'eyupsultan' limit 1),
    'Eyup Sultan Camii',
    'eyup-sultan-camii',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.9337456 41.0480113)'::geography,
    'Eyup Sultan Camii, Eyupsultan tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul','eyupsultan']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:57:52.332Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'eyupsultan' limit 1),
    'Pierre Loti',
    'pierre-loti',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.9333678 41.0532906)'::geography,
    'Pierre Loti, Eyupsultan tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul','eyupsultan']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:57:54.141Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'kadikoy' limit 1),
    'Kadikoy',
    'kadikoy',
    'beach'::public.place_category,
    'SRID=4326;POINT(29.0220448 40.9905872)'::geography,
    'Kadikoy, Kadikoy tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','i̇stanbul','kadikoy']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:57:55.940Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'kadikoy' limit 1),
    'Moda',
    'moda',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.0254706 40.9811687)'::geography,
    'Moda, Kadikoy tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul','kadikoy']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:57:57.726Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'kadikoy' limit 1),
    'Bahariye',
    'bahariye',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.030672 40.9856643)'::geography,
    'Bahariye, Kadikoy tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul','kadikoy']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:58:00.084Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'kadikoy' limit 1),
    'Haydarpasa',
    'haydarpasa',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.0192634 40.996546)'::geography,
    'Haydarpasa, Kadikoy tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul','kadikoy']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:58:02.153Z'::timestamptz,
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
    (select id from public.provinces where slug = 'istanbul' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'istanbul' and d.slug = 'sisli' limit 1),
    'Nisantasi',
    'nisantasi',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.9916962 41.0516865)'::geography,
    'Nisantasi, Sisli tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇stanbul','sisli']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:58:03.810Z'::timestamptz,
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
    (select id from public.provinces where slug = 'ankara' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'ankara' and d.slug = 'cankaya' limit 1),
    'Anitkabir',
    'anitkabir',
    'historical'::public.place_category,
    'SRID=4326;POINT(32.8365635 39.9267385)'::geography,
    'Anitkabir, Cankaya tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','ankara','cankaya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:58:05.595Z'::timestamptz,
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
    (select id from public.provinces where slug = 'ankara' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'ankara' and d.slug = 'cankaya' limit 1),
    'Atakule',
    'atakule',
    'viewpoint'::public.place_category,
    'SRID=4326;POINT(32.8561367 39.8861418)'::geography,
    'Atakule, Cankaya civarinda manzara ve fotograf icin one cikan ikonik bir noktadir.',
    'sunset'::public.best_time,
    60,
    array['must-see','iconic','ankara','cankaya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:58:07.555Z'::timestamptz,
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
    (select id from public.provinces where slug = 'ankara' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'ankara' and d.slug = 'cankaya' limit 1),
    'Kugulu Park',
    'kugulu-park',
    'historical'::public.place_category,
    'SRID=4326;POINT(32.8602164 39.9018538)'::geography,
    'Kugulu Park, Cankaya tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','ankara','cankaya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:58:11.242Z'::timestamptz,
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
    (select id from public.provinces where slug = 'ankara' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'ankara' and d.slug = 'altindag' limit 1),
    'Hamamonu',
    'hamamonu',
    'historical'::public.place_category,
    'SRID=4326;POINT(32.8660778 39.9334686)'::geography,
    'Hamamonu, Altindag tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','ankara','altindag']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:58:13.700Z'::timestamptz,
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
    (select id from public.provinces where slug = 'ankara' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'ankara' and d.slug = 'altindag' limit 1),
    'Ankara Kalesi',
    'ankara-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(32.865427 39.9414931)'::geography,
    'Ankara Kalesi, Altindag tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','ankara','altindag']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:58:15.939Z'::timestamptz,
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
    (select id from public.provinces where slug = 'ankara' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'ankara' and d.slug = 'altindag' limit 1),
    'Anadolu Medeniyetleri Muzesi',
    'anadolu-medeniyetleri-muzesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(32.8617618 39.9379477)'::geography,
    'Anadolu Medeniyetleri Muzesi, Altindag tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','ankara','altindag']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:58:17.681Z'::timestamptz,
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
    '2026-09-11T11:58:19.439Z'::timestamptz,
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
    'historical'::public.place_category,
    'SRID=4326;POINT(29.0874591 36.5781319)'::geography,
    'Kayakoy, Fethiye tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla','fethiye']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:58:21.162Z'::timestamptz,
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
    '2026-09-11T11:58:24.759Z'::timestamptz,
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
    'viewpoint'::public.place_category,
    'SRID=4326;POINT(29.1227057 36.6549053)'::geography,
    'Babadağ, Fethiye civarinda manzara ve fotograf icin one cikan ikonik bir noktadir.',
    'sunset'::public.best_time,
    60,
    array['must-see','iconic','muğla','fethiye']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:58:26.501Z'::timestamptz,
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
    'viewpoint'::public.place_category,
    'SRID=4326;POINT(29.1227057 36.6549053)'::geography,
    'Babadag, Fethiye civarinda manzara ve fotograf icin one cikan ikonik bir noktadir.',
    'sunset'::public.best_time,
    60,
    array['must-see','iconic','muğla','fethiye']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:58:28.313Z'::timestamptz,
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
    'Gocek',
    'gocek',
    'beach'::public.place_category,
    'SRID=4326;POINT(28.9422879 36.7537141)'::geography,
    'Gocek, Fethiye tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','muğla','fethiye']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:58:30.027Z'::timestamptz,
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
    'Likya Yolu',
    'likya-yolu',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.1535048 36.5118059)'::geography,
    'Likya Yolu, Fethiye tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla','fethiye']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:58:35.276Z'::timestamptz,
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
    'Calis Plaji',
    'calis-plaji',
    'beach'::public.place_category,
    'SRID=4326;POINT(29.1054533 36.6670051)'::geography,
    'Calis Plaji, Fethiye tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','muğla','fethiye']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:58:37.074Z'::timestamptz,
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
    'Hisaronu',
    'hisaronu',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.1346613 36.5719042)'::geography,
    'Hisaronu, Fethiye tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla','fethiye']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:58:38.683Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'seydikemer' limit 1),
    'Saklikent',
    'saklikent',
    'nature'::public.place_category,
    'SRID=4326;POINT(29.3748882 36.6084603)'::geography,
    'Saklikent, Seydikemer bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','muğla','seydikemer']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:58:40.505Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'seydikemer' limit 1),
    'Tlos',
    'tlos',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.4187025 36.5540176)'::geography,
    'Tlos, Seydikemer tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla','seydikemer']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:58:42.322Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'seydikemer' limit 1),
    'Gizlikent',
    'gizlikent',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.3968343 36.4844522)'::geography,
    'Gizlikent, Seydikemer tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla','seydikemer']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:58:44.042Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'seydikemer' limit 1),
    'Letoon',
    'letoon',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.2895657 36.3315757)'::geography,
    'Letoon, Seydikemer tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla','seydikemer']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:58:45.659Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'seydikemer' limit 1),
    'Pinara',
    'pinara',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.2560605 36.4900916)'::geography,
    'Pinara, Seydikemer tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla','seydikemer']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:58:48.995Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'ortaca' limit 1),
    'Iztuzu Plaji',
    'iztuzu-plaji',
    'beach'::public.place_category,
    'SRID=4326;POINT(28.6250016 36.7885353)'::geography,
    'Iztuzu Plaji, Ortaca tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','muğla','ortaca']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:58:50.651Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'ortaca' limit 1),
    'Dalyan',
    'dalyan',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.6423915 36.8350176)'::geography,
    'Dalyan, Ortaca tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla','ortaca']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:58:52.381Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'ortaca' limit 1),
    'Kaunos',
    'kaunos',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.6242516 36.8245236)'::geography,
    'Kaunos, Ortaca tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla','ortaca']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:58:54.065Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'koycegiz' limit 1),
    'Koycegiz Golu',
    'koycegiz-golu',
    'beach'::public.place_category,
    'SRID=4326;POINT(28.6542344 36.9061963)'::geography,
    'Koycegiz Golu, Koycegiz tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','muğla','koycegiz']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:58:57.258Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'koycegiz' limit 1),
    'Sultaniye Kaplicalari',
    'sultaniye-kaplicalari',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.6026218 36.8737069)'::geography,
    'Sultaniye Kaplicalari, Koycegiz tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla','koycegiz']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:58:59.166Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'dalaman' limit 1),
    'Dalaman',
    'dalaman',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.7857838 36.7118309)'::geography,
    'Dalaman, Dalaman tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla','dalaman']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:59:03.025Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'milas' limit 1),
    'Labranda',
    'labranda',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.8199993 37.4188888)'::geography,
    'Labranda, Milas tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla','milas']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:59:05.276Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'milas' limit 1),
    'Becin',
    'becin',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.7958452 37.2748888)'::geography,
    'Becin, Milas tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla','milas']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:59:07.443Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'milas' limit 1),
    'Euromos',
    'euromos',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.6750765 37.3743507)'::geography,
    'Euromos, Milas tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla','milas']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:59:12.195Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'bodrum' limit 1),
    'Bodrum Kalesi',
    'bodrum-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.4291029 37.0317673)'::geography,
    'Bodrum Kalesi, Bodrum tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla','bodrum']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:59:14.117Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'bodrum' limit 1),
    'Gumusluk',
    'gumusluk',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.2366323 37.0535073)'::geography,
    'Gumusluk, Bodrum tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla','bodrum']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:59:17.459Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'bodrum' limit 1),
    'Yalikavak',
    'yalikavak',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.293058 37.1056168)'::geography,
    'Yalikavak, Bodrum tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla','bodrum']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:59:19.122Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'bodrum' limit 1),
    'Halikarnas',
    'halikarnas',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.4241455 37.0378827)'::geography,
    'Halikarnas, Bodrum tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla','bodrum']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:59:20.851Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'bodrum' limit 1),
    'Turgutreis',
    'turgutreis',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.2578341 37.0057722)'::geography,
    'Turgutreis, Bodrum tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla','bodrum']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:59:23.948Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'bodrum' limit 1),
    'Gumbet',
    'gumbet',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.4049706 37.0331908)'::geography,
    'Gumbet, Bodrum tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla','bodrum']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:59:25.706Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'bodrum' limit 1),
    'Torba',
    'torba',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.4590454 37.074401)'::geography,
    'Torba, Bodrum tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla','bodrum']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:59:27.535Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'datca' limit 1),
    'Knidos',
    'knidos',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.3739492 36.686356)'::geography,
    'Knidos, Datca tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla','datca']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:59:29.273Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'datca' limit 1),
    'Eski Datca',
    'eski-datca',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.6649668 36.7391152)'::geography,
    'Eski Datca, Datca tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla','datca']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:59:31.099Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'datca' limit 1),
    'Palamutbuku',
    'palamutbuku',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.503593 36.6744763)'::geography,
    'Palamutbuku, Datca tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla','datca']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:59:34.514Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'ula' limit 1),
    'Azmak',
    'azmak',
    'nature'::public.place_category,
    'SRID=4326;POINT(28.3373371 37.0552283)'::geography,
    'Azmak, Ula bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','muğla','ula']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:59:36.196Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'ula' limit 1),
    'Akyaka',
    'akyaka',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.3271055 37.0580313)'::geography,
    'Akyaka, Ula tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla','ula']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:59:38.391Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'ula' limit 1),
    'Ula',
    'ula',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.38601 37.1294555)'::geography,
    'Ula, Ula tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla','ula']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:59:40.637Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'marmaris' limit 1),
    'Icmeler',
    'icmeler',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.2313578 36.8013283)'::geography,
    'Icmeler, Marmaris tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla','marmaris']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:59:42.458Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'marmaris' limit 1),
    'Bozburun',
    'bozburun',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.0442768 36.6927783)'::geography,
    'Bozburun, Marmaris tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla','marmaris']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:59:45.531Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'marmaris' limit 1),
    'Marmaris Kalesi',
    'marmaris-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.2740862 36.8505746)'::geography,
    'Marmaris Kalesi, Marmaris tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla','marmaris']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:59:47.238Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'marmaris' limit 1),
    'Turunc',
    'turunc',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.2467298 36.7728847)'::geography,
    'Turunc, Marmaris tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla','marmaris']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:59:49.549Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'marmaris' limit 1),
    'Hisaronu',
    'hisaronu',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.1452284 36.8000873)'::geography,
    'Hisaronu, Marmaris tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla','marmaris']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:59:51.296Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'yatagan' limit 1),
    'Stratonikeia',
    'stratonikeia',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.0653697 37.3128877)'::geography,
    'Stratonikeia, Yatagan tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla','yatagan']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:59:53.091Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'yatagan' limit 1),
    'Lagina',
    'lagina',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.0398053 37.3779468)'::geography,
    'Lagina, Yatagan tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla','yatagan']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:59:54.937Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'yatagan' limit 1),
    'Turgut',
    'turgut',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.0299607 37.3729253)'::geography,
    'Turgut, Yatagan tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla','yatagan']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:59:56.716Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mugla' and d.slug = 'kavaklidere' limit 1),
    'Kavaklidere',
    'kavaklidere',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.2599936 37.4247871)'::geography,
    'Kavaklidere, Kavaklidere tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muğla','kavaklidere']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T11:59:58.460Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'antalya' and d.slug = 'muratpasa' limit 1),
    'Kaleici',
    'kaleici',
    'historical'::public.place_category,
    'SRID=4326;POINT(30.707878 36.8840816)'::geography,
    'Kaleici, Muratpasa tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','antalya','muratpasa']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:00:00.827Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'antalya' and d.slug = 'muratpasa' limit 1),
    'Duden Selalesi',
    'duden-selalesi',
    'nature'::public.place_category,
    'SRID=4326;POINT(30.7834957 36.8509547)'::geography,
    'Duden Selalesi, Muratpasa bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','antalya','muratpasa']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:00:04.633Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'antalya' and d.slug = 'kepez' limit 1),
    'Duden Selalesi',
    'duden-selalesi',
    'nature'::public.place_category,
    'SRID=4326;POINT(30.726664 36.9648286)'::geography,
    'Duden Selalesi, Kepez bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','antalya','kepez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:00:10.185Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'antalya' and d.slug = 'dosemealti' limit 1),
    'Termessos',
    'termessos',
    'historical'::public.place_category,
    'SRID=4326;POINT(30.464388 36.9821814)'::geography,
    'Termessos, Dosemealti tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','antalya','dosemealti']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:00:12.021Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'antalya' and d.slug = 'dosemealti' limit 1),
    'Karain Magarasi',
    'karain-magarasi',
    'nature'::public.place_category,
    'SRID=4326;POINT(30.5706249 37.077831)'::geography,
    'Karain Magarasi, Dosemealti bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','antalya','dosemealti']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:00:13.773Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'antalya' and d.slug = 'aksu' limit 1),
    'Aksu',
    'aksu',
    'historical'::public.place_category,
    'SRID=4326;POINT(30.8457671 36.9479401)'::geography,
    'Aksu, Aksu tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','antalya','aksu']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:00:17.080Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'antalya' and d.slug = 'kas' limit 1),
    'Kaputas',
    'kaputas',
    'beach'::public.place_category,
    'SRID=4326;POINT(29.4491601 36.2288242)'::geography,
    'Kaputas, Kas tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','antalya','kas']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:00:20.168Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'antalya' and d.slug = 'kas' limit 1),
    'Patara',
    'patara',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.3179562 36.2611865)'::geography,
    'Patara, Kas tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','antalya','kas']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:00:22.525Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'antalya' and d.slug = 'kas' limit 1),
    'Simena',
    'simena',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.6498577 36.1936071)'::geography,
    'Simena, Kas tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','antalya','kas']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:00:25.668Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'antalya' and d.slug = 'kas' limit 1),
    'Antiphellos',
    'antiphellos',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.6349491 36.1999876)'::geography,
    'Antiphellos, Kas tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','antalya','kas']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:00:27.399Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'antalya' and d.slug = 'kemer' limit 1),
    'Olympos',
    'olympos',
    'historical'::public.place_category,
    'SRID=4326;POINT(30.4868668 36.5408838)'::geography,
    'Olympos, Kemer tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','antalya','kemer']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:00:29.283Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'antalya' and d.slug = 'manavgat' limit 1),
    'Side',
    'side',
    'historical'::public.place_category,
    'SRID=4326;POINT(31.3892197 36.7664439)'::geography,
    'Side, Manavgat tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','antalya','manavgat']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:00:34.502Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'antalya' and d.slug = 'manavgat' limit 1),
    'Manavgat Selalesi',
    'manavgat-selalesi',
    'nature'::public.place_category,
    'SRID=4326;POINT(31.4544432 36.8135429)'::geography,
    'Manavgat Selalesi, Manavgat bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','antalya','manavgat']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:00:36.961Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'antalya' and d.slug = 'manavgat' limit 1),
    'Koprulu Kanyon',
    'koprulu-kanyon',
    'nature'::public.place_category,
    'SRID=4326;POINT(31.1804494 37.1876855)'::geography,
    'Koprulu Kanyon, Manavgat bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','antalya','manavgat']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:00:38.721Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'antalya' and d.slug = 'demre' limit 1),
    'Myra',
    'myra',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.9852046 36.2587484)'::geography,
    'Myra, Demre tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','antalya','demre']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:00:43.865Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'antalya' and d.slug = 'demre' limit 1),
    'Kekova',
    'kekova',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.877452 36.1824129)'::geography,
    'Kekova, Demre tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','antalya','demre']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:00:46.511Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'antalya' and d.slug = 'demre' limit 1),
    'Noel Baba Kilisesi',
    'noel-baba-kilisesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.9854189 36.2447452)'::geography,
    'Noel Baba Kilisesi, Demre tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','antalya','demre']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:00:48.769Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'antalya' and d.slug = 'alanya' limit 1),
    'Alanya Kalesi',
    'alanya-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(31.9905642 36.5331062)'::geography,
    'Alanya Kalesi, Alanya tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','antalya','alanya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:00:50.533Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'antalya' and d.slug = 'alanya' limit 1),
    'Damlatas Magarasi',
    'damlatas-magarasi',
    'nature'::public.place_category,
    'SRID=4326;POINT(31.9887906 36.5418683)'::geography,
    'Damlatas Magarasi, Alanya bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','antalya','alanya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:00:53.681Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'antalya' and d.slug = 'alanya' limit 1),
    'Dim Cay',
    'dim-cay',
    'historical'::public.place_category,
    'SRID=4326;POINT(32.0547341 36.5223957)'::geography,
    'Dim Cay, Alanya tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','antalya','alanya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:00:55.661Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'antalya' and d.slug = 'alanya' limit 1),
    'Kleopatra Plaji',
    'kleopatra-plaji',
    'beach'::public.place_category,
    'SRID=4326;POINT(31.9799888 36.5483019)'::geography,
    'Kleopatra Plaji, Alanya tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','antalya','alanya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:00:57.811Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'antalya' and d.slug = 'alanya' limit 1),
    'Kizil Kule',
    'kizil-kule',
    'viewpoint'::public.place_category,
    'SRID=4326;POINT(31.9982536 36.5363909)'::geography,
    'Kizil Kule, Alanya civarinda manzara ve fotograf icin one cikan ikonik bir noktadir.',
    'sunset'::public.best_time,
    60,
    array['must-see','iconic','antalya','alanya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:01:00.316Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'antalya' and d.slug = 'serik' limit 1),
    'Aspendos',
    'aspendos',
    'historical'::public.place_category,
    'SRID=4326;POINT(31.1696915 36.940401)'::geography,
    'Aspendos, Serik tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','antalya','serik']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:01:02.543Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'antalya' and d.slug = 'serik' limit 1),
    'Belek',
    'belek',
    'historical'::public.place_category,
    'SRID=4326;POINT(31.0578184 36.8633459)'::geography,
    'Belek, Serik tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','antalya','serik']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:01:04.718Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'antalya' and d.slug = 'serik' limit 1),
    'Sillyon',
    'sillyon',
    'historical'::public.place_category,
    'SRID=4326;POINT(30.9883517 36.9916344)'::geography,
    'Sillyon, Serik tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','antalya','serik']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:01:06.434Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'antalya' and d.slug = 'finike' limit 1),
    'Limyra',
    'limyra',
    'historical'::public.place_category,
    'SRID=4326;POINT(30.1667053 36.3437046)'::geography,
    'Limyra, Finike tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','antalya','finike']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:01:08.178Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'antalya' and d.slug = 'akseki' limit 1),
    'Akseki',
    'akseki',
    'historical'::public.place_category,
    'SRID=4326;POINT(31.759441 37.0108895)'::geography,
    'Akseki, Akseki tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','antalya','akseki']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:01:14.519Z'::timestamptz,
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
    (select id from public.provinces where slug = 'antalya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'antalya' and d.slug = 'gundogmus' limit 1),
    'Gundogmus',
    'gundogmus',
    'historical'::public.place_category,
    'SRID=4326;POINT(32.0004859 36.8099445)'::geography,
    'Gundogmus, Gundogmus tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','antalya','gundogmus']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:01:18.343Z'::timestamptz,
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
    (select id from public.provinces where slug = 'sakarya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'sakarya' and d.slug = 'sapanca' limit 1),
    'Sapanca Golu',
    'sapanca-golu',
    'nature'::public.place_category,
    'SRID=4326;POINT(30.2420272 40.7172304)'::geography,
    'Sapanca Golu, Sapanca bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','sakarya','sapanca']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:01:19.954Z'::timestamptz,
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
    (select id from public.provinces where slug = 'mersin' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mersin' and d.slug = 'erdemli' limit 1),
    'Kizkalesi',
    'kizkalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.1484522 36.4567784)'::geography,
    'Kizkalesi, Erdemli tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','mersin','erdemli']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:01:21.684Z'::timestamptz,
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
    (select id from public.provinces where slug = 'mersin' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mersin' and d.slug = 'tarsus' limit 1),
    'Tarsus Selalesi',
    'tarsus-selalesi',
    'nature'::public.place_category,
    'SRID=4326;POINT(34.898408 36.9333126)'::geography,
    'Tarsus Selalesi, Tarsus bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','mersin','tarsus']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:01:25.292Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bursa' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'bursa' and d.slug = 'osmangazi' limit 1),
    'Ulu Cami',
    'ulu-cami',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.0618995 40.1838059)'::geography,
    'Ulu Cami, Osmangazi tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','bursa','osmangazi']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:01:27.085Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bursa' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'bursa' and d.slug = 'osmangazi' limit 1),
    'Kapali Carsi',
    'kapali-carsi',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.0626823 40.1845383)'::geography,
    'Kapali Carsi, Osmangazi tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','bursa','osmangazi']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:01:28.894Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bursa' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'bursa' and d.slug = 'osmangazi' limit 1),
    'Setbasi',
    'setbasi',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.0701133 40.1833068)'::geography,
    'Setbasi, Osmangazi tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','bursa','osmangazi']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:01:30.989Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bursa' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'bursa' and d.slug = 'nilufer' limit 1),
    'Golyazi',
    'golyazi',
    'nature'::public.place_category,
    'SRID=4326;POINT(28.6775511 40.1653978)'::geography,
    'Golyazi, Nilufer bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','bursa','nilufer']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:01:32.773Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bursa' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'bursa' and d.slug = 'yildirim' limit 1),
    'Cumalikizik',
    'cumalikizik',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.1726885 40.1752128)'::geography,
    'Cumalikizik, Yildirim tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','bursa','yildirim']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:01:35.005Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bursa' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'bursa' and d.slug = 'mudanya' limit 1),
    'Tirilye',
    'tirilye',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.7962239 40.3927446)'::geography,
    'Tirilye, Mudanya tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','bursa','mudanya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:01:39.968Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bursa' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'bursa' and d.slug = 'uludag' limit 1),
    'Uludag',
    'uludag',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.8697527 40.238967)'::geography,
    'Uludag, Uludag tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','bursa','uludag']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:01:42.531Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bursa' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'bursa' and d.slug = 'iznik' limit 1),
    'Iznik',
    'iznik',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.720685 40.4240799)'::geography,
    'Iznik, Iznik tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','bursa','iznik']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:01:50.410Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bursa' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'bursa' and d.slug = 'inegol' limit 1),
    'Inegol',
    'inegol',
    'nature'::public.place_category,
    'SRID=4326;POINT(29.5454836 40.1586918)'::geography,
    'Inegol, Inegol bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','bursa','inegol']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:01:52.243Z'::timestamptz,
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
    (select id from public.provinces where slug = 'karabuk' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'karabuk' and d.slug = 'safranbolu' limit 1),
    'Safranbolu',
    'safranbolu',
    'historical'::public.place_category,
    'SRID=4326;POINT(32.6942103 41.2400453)'::geography,
    'Safranbolu, Safranbolu tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','karabük','safranbolu']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:02:19.145Z'::timestamptz,
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
    (select id from public.provinces where slug = 'karabuk' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'karabuk' and d.slug = 'safranbolu' limit 1),
    'Kaymakamlar Evi',
    'kaymakamlar-evi',
    'historical'::public.place_category,
    'SRID=4326;POINT(32.6941913 41.244129)'::geography,
    'Kaymakamlar Evi, Safranbolu tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','karabük','safranbolu']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:02:22.571Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bolu' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'bolu' and d.slug = 'golkoy' limit 1),
    'Abant',
    'abant',
    'historical'::public.place_category,
    'SRID=4326;POINT(31.5271807 40.7166979)'::geography,
    'Abant, Golkoy tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','bolu','golkoy']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:02:32.265Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bolu' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'bolu' and d.slug = 'mengen' limit 1),
    'Yedigoller',
    'yedigoller',
    'nature'::public.place_category,
    'SRID=4326;POINT(32.0113058 40.9990429)'::geography,
    'Yedigoller, Mengen bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','bolu','mengen']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:02:53.691Z'::timestamptz,
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
    (select id from public.provinces where slug = 'rize' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'rize' and d.slug = 'camlihemsin' limit 1),
    'Ayder',
    'ayder',
    'historical'::public.place_category,
    'SRID=4326;POINT(41.1020508 40.9525203)'::geography,
    'Ayder, Camlihemsin tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','rize','camlihemsin']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:03:00.835Z'::timestamptz,
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
    (select id from public.provinces where slug = 'rize' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'rize' and d.slug = 'camlihemsin' limit 1),
    'Ayder Yaylasi',
    'ayder-yaylasi',
    'historical'::public.place_category,
    'SRID=4326;POINT(41.1020508 40.9525203)'::geography,
    'Ayder Yaylasi, Camlihemsin tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','rize','camlihemsin']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:03:02.880Z'::timestamptz,
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
    (select id from public.provinces where slug = 'rize' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'rize' and d.slug = 'camlihemsin' limit 1),
    'Firtina Deresi',
    'firtina-deresi',
    'historical'::public.place_category,
    'SRID=4326;POINT(41.0060077 41.053474)'::geography,
    'Firtina Deresi, Camlihemsin tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','rize','camlihemsin']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:03:04.725Z'::timestamptz,
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
    (select id from public.provinces where slug = 'rize' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'rize' and d.slug = 'merkez' limit 1),
    'Rize Kalesi',
    'rize-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(40.510132 41.0276353)'::geography,
    'Rize Kalesi, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','rize','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:03:06.949Z'::timestamptz,
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
    (select id from public.provinces where slug = 'artvin' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'artvin' and d.slug = 'borcka' limit 1),
    'Karagol',
    'karagol',
    'nature'::public.place_category,
    'SRID=4326;POINT(41.8542248 41.385221)'::geography,
    'Karagol, Borcka bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','artvin','borcka']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:03:13.123Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kars' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'kars' and d.slug = 'merkez' limit 1),
    'Kars Kalesi',
    'kars-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(43.0899656 40.6134666)'::geography,
    'Kars Kalesi, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','kars','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:03:18.717Z'::timestamptz,
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
    (select id from public.provinces where slug = 'agri' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'agri' and d.slug = 'dogubayazit' limit 1),
    'Ishak Pasa Sarayi',
    'ishak-pasa-sarayi',
    'historical'::public.place_category,
    'SRID=4326;POINT(44.1296852 39.5203827)'::geography,
    'Ishak Pasa Sarayi, Dogubayazit tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','ağrı','dogubayazit']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:03:26.947Z'::timestamptz,
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
    (select id from public.provinces where slug = 'agri' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'agri' and d.slug = 'dogubayazit' limit 1),
    'Agri Dagi',
    'agri-dagi',
    'historical'::public.place_category,
    'SRID=4326;POINT(44.4138156 39.6482053)'::geography,
    'Agri Dagi, Dogubayazit tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','ağrı','dogubayazit']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:03:28.842Z'::timestamptz,
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
    (select id from public.provinces where slug = 'van' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'van' and d.slug = 'edremit' limit 1),
    'Van Golu',
    'van-golu',
    'nature'::public.place_category,
    'SRID=4326;POINT(43.3225415 38.4685451)'::geography,
    'Van Golu, Edremit bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','van','edremit']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:03:32.105Z'::timestamptz,
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
    (select id from public.provinces where slug = 'van' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'van' and d.slug = 'muradiye' limit 1),
    'Muradiye Selalesi',
    'muradiye-selalesi',
    'nature'::public.place_category,
    'SRID=4326;POINT(43.7567753 39.0566497)'::geography,
    'Muradiye Selalesi, Muradiye bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','van','muradiye']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:03:48.707Z'::timestamptz,
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
    (select id from public.provinces where slug = 'konya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'konya' and d.slug = 'cumra' limit 1),
    'Catalhoyuk',
    'catalhoyuk',
    'historical'::public.place_category,
    'SRID=4326;POINT(32.8252568 37.6667937)'::geography,
    'Catalhoyuk, Cumra tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','konya','cumra']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:03:56.222Z'::timestamptz,
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
    (select id from public.provinces where slug = 'konya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'konya' and d.slug = 'beysehir' limit 1),
    'Eflatunpinar',
    'eflatunpinar',
    'historical'::public.place_category,
    'SRID=4326;POINT(31.6746191 37.8255799)'::geography,
    'Eflatunpinar, Beysehir tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','konya','beysehir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:04:01.819Z'::timestamptz,
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
    (select id from public.provinces where slug = 'konya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'konya' and d.slug = 'seydisehir' limit 1),
    'Seydisehir',
    'seydisehir',
    'historical'::public.place_category,
    'SRID=4326;POINT(31.8521726 37.4412707)'::geography,
    'Seydisehir, Seydisehir tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','konya','seydisehir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:04:03.641Z'::timestamptz,
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
    (select id from public.provinces where slug = 'konya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'konya' and d.slug = 'seydisehir' limit 1),
    'Sugla Golu',
    'sugla-golu',
    'nature'::public.place_category,
    'SRID=4326;POINT(32.0021734 37.329095)'::geography,
    'Sugla Golu, Seydisehir bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','konya','seydisehir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:04:05.460Z'::timestamptz,
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
    (select id from public.provinces where slug = 'denizli' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'denizli' and d.slug = 'pamukkale' limit 1),
    'Pamukkale',
    'pamukkale',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.1217529 37.9200382)'::geography,
    'Pamukkale, Pamukkale tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','denizli','pamukkale']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:04:07.176Z'::timestamptz,
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
    (select id from public.provinces where slug = 'denizli' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'denizli' and d.slug = 'pamukkale' limit 1),
    'Hierapolis',
    'hierapolis',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.1263634 37.9309549)'::geography,
    'Hierapolis, Pamukkale tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','denizli','pamukkale']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:04:09.015Z'::timestamptz,
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
    (select id from public.provinces where slug = 'canakkale' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'canakkale' and d.slug = 'merkez' limit 1),
    'Troya',
    'troya',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.2380175 39.957374)'::geography,
    'Troya, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','çanakkale','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:04:21.424Z'::timestamptz,
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
    (select id from public.provinces where slug = 'canakkale' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'canakkale' and d.slug = 'bozcaada' limit 1),
    'Bozcaada',
    'bozcaada',
    'beach'::public.place_category,
    'SRID=4326;POINT(26.0395466 39.8170524)'::geography,
    'Bozcaada, Bozcaada tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','çanakkale','bozcaada']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:04:24.983Z'::timestamptz,
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
    (select id from public.provinces where slug = 'canakkale' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'canakkale' and d.slug = 'bozcaada' limit 1),
    'Bozcaada Kalesi',
    'bozcaada-kalesi',
    'beach'::public.place_category,
    'SRID=4326;POINT(26.072448 39.8361565)'::geography,
    'Bozcaada Kalesi, Bozcaada tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','çanakkale','bozcaada']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:04:26.779Z'::timestamptz,
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
    (select id from public.provinces where slug = 'canakkale' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'canakkale' and d.slug = 'gokceada' limit 1),
    'Gokceada',
    'gokceada',
    'beach'::public.place_category,
    'SRID=4326;POINT(25.9084625 40.2003874)'::geography,
    'Gokceada, Gokceada tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','çanakkale','gokceada']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:04:28.568Z'::timestamptz,
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
    (select id from public.provinces where slug = 'canakkale' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'canakkale' and d.slug = 'gokceada' limit 1),
    'Kaleköy',
    'kalekoy',
    'beach'::public.place_category,
    'SRID=4326;POINT(25.8985823 40.2335474)'::geography,
    'Kaleköy, Gokceada tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','çanakkale','gokceada']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:04:30.384Z'::timestamptz,
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
    (select id from public.provinces where slug = 'canakkale' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'canakkale' and d.slug = 'ayvacik' limit 1),
    'Assos',
    'assos',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.3361336 39.4889415)'::geography,
    'Assos, Ayvacik tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','çanakkale','ayvacik']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:04:33.259Z'::timestamptz,
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
    (select id from public.provinces where slug = 'canakkale' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'canakkale' and d.slug = 'ayvacik' limit 1),
    'Babakale',
    'babakale',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.0648664 39.4797366)'::geography,
    'Babakale, Ayvacik tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','çanakkale','ayvacik']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:04:34.935Z'::timestamptz,
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
    (select id from public.provinces where slug = 'aydin' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'aydin' and d.slug = 'selcuk' limit 1),
    'Efes',
    'efes',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.2722794 37.9153259)'::geography,
    'Efes, Selcuk tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','aydın','selcuk']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:04:36.723Z'::timestamptz,
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
    (select id from public.provinces where slug = 'aydin' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'aydin' and d.slug = 'didim' limit 1),
    'Didim',
    'didim',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.2619701 37.3386677)'::geography,
    'Didim, Didim tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','aydın','didim']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:04:42.874Z'::timestamptz,
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
    (select id from public.provinces where slug = 'aydin' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'aydin' and d.slug = 'didim' limit 1),
    'Apollon Tapinagi',
    'apollon-tapinagi',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.25636 37.3849478)'::geography,
    'Apollon Tapinagi, Didim tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','aydın','didim']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:04:44.651Z'::timestamptz,
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
    (select id from public.provinces where slug = 'aydin' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'aydin' and d.slug = 'kusadasi' limit 1),
    'Kadikalesi',
    'kadikalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.2691296 37.7893839)'::geography,
    'Kadikalesi, Kusadasi tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','aydın','kusadasi']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:04:47.989Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'izmir' and d.slug = 'selcuk' limit 1),
    'Efes',
    'efes',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.3393194 37.9404456)'::geography,
    'Efes, Selcuk tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir','selcuk']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:04:51.837Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'izmir' and d.slug = 'selcuk' limit 1),
    'Meryem Ana',
    'meryem-ana',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.3340134 37.9115563)'::geography,
    'Meryem Ana, Selcuk tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir','selcuk']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:04:53.977Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'izmir' and d.slug = 'selcuk' limit 1),
    'Sirince',
    'sirince',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.4328343 37.9423518)'::geography,
    'Sirince, Selcuk tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir','selcuk']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:04:56.304Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'izmir' and d.slug = 'selcuk' limit 1),
    'Artemis Tapinagi',
    'artemis-tapinagi',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.3636333 37.9497968)'::geography,
    'Artemis Tapinagi, Selcuk tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir','selcuk']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:04:58.057Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'izmir' and d.slug = 'selcuk' limit 1),
    'Isa Bey Camii',
    'isa-bey-camii',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.3658768 37.9521132)'::geography,
    'Isa Bey Camii, Selcuk tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir','selcuk']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:05:00.733Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'izmir' and d.slug = 'konak' limit 1),
    'Saat Kulesi',
    'saat-kulesi',
    'viewpoint'::public.place_category,
    'SRID=4326;POINT(27.1286959 38.4188623)'::geography,
    'Saat Kulesi, Konak civarinda manzara ve fotograf icin one cikan ikonik bir noktadir.',
    'sunset'::public.best_time,
    60,
    array['must-see','iconic','i̇zmir','konak']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:05:02.922Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'izmir' and d.slug = 'konak' limit 1),
    'Kemeralti',
    'kemeralti',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.1326935 38.4191798)'::geography,
    'Kemeralti, Konak tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir','konak']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:05:05.173Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'izmir' and d.slug = 'konak' limit 1),
    'Kordon',
    'kordon',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.1376895 38.4328514)'::geography,
    'Kordon, Konak tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir','konak']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:05:16.259Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'izmir' and d.slug = 'konak' limit 1),
    'Asansor',
    'asansor',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.117476 38.4087859)'::geography,
    'Asansor, Konak tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir','konak']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:05:23.068Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'izmir' and d.slug = 'cesme' limit 1),
    'Alacati',
    'alacati',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.3745176 38.2847573)'::geography,
    'Alacati, Cesme tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir','cesme']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:05:27.333Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'izmir' and d.slug = 'cesme' limit 1),
    'Ilica',
    'ilica',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.3607464 38.3083827)'::geography,
    'Ilica, Cesme tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir','cesme']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:05:29.790Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'izmir' and d.slug = 'cesme' limit 1),
    'Cesme Kalesi',
    'cesme-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.3039793 38.323578)'::geography,
    'Cesme Kalesi, Cesme tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir','cesme']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:05:35.585Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'izmir' and d.slug = 'bergama' limit 1),
    'Asklepion',
    'asklepion',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.1656658 39.1189248)'::geography,
    'Asklepion, Bergama tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir','bergama']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:05:40.395Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'izmir' and d.slug = 'bergama' limit 1),
    'Kizil Avlu',
    'kizil-avlu',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.1833594 39.1216173)'::geography,
    'Kizil Avlu, Bergama tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir','bergama']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:05:43.064Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'izmir' and d.slug = 'bergama' limit 1),
    'Bergama Muzesi',
    'bergama-muzesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.1762032 39.1164932)'::geography,
    'Bergama Muzesi, Bergama tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir','bergama']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:05:44.987Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'izmir' and d.slug = 'odemis' limit 1),
    'Birgi',
    'birgi',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.0654953 38.2541385)'::geography,
    'Birgi, Odemis tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir','odemis']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:05:50.405Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'izmir' and d.slug = 'foca' limit 1),
    'Foca',
    'foca',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.7640509 38.6419545)'::geography,
    'Foca, Foca tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir','foca']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:05:53.874Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'izmir' and d.slug = 'foca' limit 1),
    'Phokaia',
    'phokaia',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.7377427 38.6883783)'::geography,
    'Phokaia, Foca tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir','foca']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:05:57.823Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'izmir' and d.slug = 'seferihisar' limit 1),
    'Seferihisar',
    'seferihisar',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.8433589 38.1226271)'::geography,
    'Seferihisar, Seferihisar tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir','seferihisar']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:06:01.591Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'izmir' and d.slug = 'seferihisar' limit 1),
    'Teos',
    'teos',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.7830734 38.1797407)'::geography,
    'Teos, Seferihisar tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir','seferihisar']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:06:03.463Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'izmir' and d.slug = 'seferihisar' limit 1),
    'Sigacik',
    'sigacik',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.7844611 38.1945123)'::geography,
    'Sigacik, Seferihisar tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir','seferihisar']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:06:05.501Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'izmir' and d.slug = 'urla' limit 1),
    'Urla',
    'urla',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.7822753 38.3173049)'::geography,
    'Urla, Urla tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir','urla']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:06:08.817Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'izmir' and d.slug = 'urla' limit 1),
    'Klazomenai',
    'klazomenai',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.7704697 38.3619899)'::geography,
    'Klazomenai, Urla tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir','urla']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:06:10.609Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'izmir' and d.slug = 'menderes' limit 1),
    'Claros',
    'claros',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.1930661 38.0516322)'::geography,
    'Claros, Menderes tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir','menderes']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:06:13.736Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'izmir' and d.slug = 'dikili' limit 1),
    'Dikili',
    'dikili',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.8864617 39.0704923)'::geography,
    'Dikili, Dikili tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir','dikili']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:06:26.456Z'::timestamptz,
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
    (select id from public.provinces where slug = 'izmir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'izmir' and d.slug = 'dikili' limit 1),
    'Bademli',
    'bademli',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.8246982 39.0279997)'::geography,
    'Bademli, Dikili tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','i̇zmir','dikili']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:06:28.316Z'::timestamptz,
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
    (select id from public.provinces where slug = 'hatay' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'hatay' and d.slug = 'altinozu' limit 1),
    'Harbiye Selalesi',
    'harbiye-selalesi',
    'nature'::public.place_category,
    'SRID=4326;POINT(36.1662266 36.1315794)'::geography,
    'Harbiye Selalesi, Altinozu bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','hatay','altinozu']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:06:33.078Z'::timestamptz,
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
    (select id from public.provinces where slug = 'hatay' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'hatay' and d.slug = 'antakya' limit 1),
    'Uzun Carsi',
    'uzun-carsi',
    'historical'::public.place_category,
    'SRID=4326;POINT(36.1628646 36.2027447)'::geography,
    'Uzun Carsi, Antakya tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','hatay','antakya']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:06:35.567Z'::timestamptz,
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
    (select id from public.provinces where slug = 'sanliurfa' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'sanliurfa' and d.slug = 'haliliye' limit 1),
    'Gobeklitepe',
    'gobeklitepe',
    'viewpoint'::public.place_category,
    'SRID=4326;POINT(38.9206472 37.2233511)'::geography,
    'Gobeklitepe, Haliliye civarinda manzara ve fotograf icin one cikan ikonik bir noktadir.',
    'sunset'::public.best_time,
    60,
    array['must-see','iconic','şanlıurfa','haliliye']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:06:41.405Z'::timestamptz,
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
    (select id from public.provinces where slug = 'sanliurfa' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'sanliurfa' and d.slug = 'haliliye' limit 1),
    'Karahantepe',
    'karahantepe',
    'viewpoint'::public.place_category,
    'SRID=4326;POINT(39.3026747 37.0916583)'::geography,
    'Karahantepe, Haliliye civarinda manzara ve fotograf icin one cikan ikonik bir noktadir.',
    'sunset'::public.best_time,
    60,
    array['must-see','iconic','şanlıurfa','haliliye']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:06:43.249Z'::timestamptz,
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
    (select id from public.provinces where slug = 'sanliurfa' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'sanliurfa' and d.slug = 'harran' limit 1),
    'Harran',
    'harran',
    'historical'::public.place_category,
    'SRID=4326;POINT(39.0299134 36.8629297)'::geography,
    'Harran, Harran tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','şanlıurfa','harran']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:06:47.057Z'::timestamptz,
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
    (select id from public.provinces where slug = 'gaziantep' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'gaziantep' and d.slug = 'sahinbey' limit 1),
    'Zeugma',
    'zeugma',
    'historical'::public.place_category,
    'SRID=4326;POINT(37.3242598 37.0433046)'::geography,
    'Zeugma, Sahinbey tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','gaziantep','sahinbey']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:06:48.770Z'::timestamptz,
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
    (select id from public.provinces where slug = 'gaziantep' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'gaziantep' and d.slug = 'sahinbey' limit 1),
    'Gaziantep Kalesi',
    'gaziantep-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(37.3832064 37.0664591)'::geography,
    'Gaziantep Kalesi, Sahinbey tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','gaziantep','sahinbey']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:06:52.980Z'::timestamptz,
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
    (select id from public.provinces where slug = 'gaziantep' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'gaziantep' and d.slug = 'sahinbey' limit 1),
    'Bakircilar Carsisi',
    'bakircilar-carsisi',
    'historical'::public.place_category,
    'SRID=4326;POINT(37.3864207 37.0622505)'::geography,
    'Bakircilar Carsisi, Sahinbey tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','gaziantep','sahinbey']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:06:54.738Z'::timestamptz,
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
    (select id from public.provinces where slug = 'mardin' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mardin' and d.slug = 'midyat' limit 1),
    'Midyat',
    'midyat',
    'historical'::public.place_category,
    'SRID=4326;POINT(41.3910054 37.4117974)'::geography,
    'Midyat, Midyat tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','mardin','midyat']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:07:02.625Z'::timestamptz,
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
    (select id from public.provinces where slug = 'mardin' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mardin' and d.slug = 'midyat' limit 1),
    'Mor Gabriel Manastiri',
    'mor-gabriel-manastiri',
    'historical'::public.place_category,
    'SRID=4326;POINT(41.5359966 37.3238604)'::geography,
    'Mor Gabriel Manastiri, Midyat tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','mardin','midyat']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:07:08.235Z'::timestamptz,
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
    (select id from public.provinces where slug = 'mardin' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mardin' and d.slug = 'nusaybin' limit 1),
    'Nusaybin',
    'nusaybin',
    'historical'::public.place_category,
    'SRID=4326;POINT(41.2281964 37.0757769)'::geography,
    'Nusaybin, Nusaybin tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','mardin','nusaybin']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:07:10.087Z'::timestamptz,
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
    (select id from public.provinces where slug = 'diyarbakir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'diyarbakir' and d.slug = 'sur' limit 1),
    'Diyarbakir Surlari',
    'diyarbakir-surlari',
    'historical'::public.place_category,
    'SRID=4326;POINT(40.2371428 37.9162655)'::geography,
    'Diyarbakir Surlari, Sur tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','diyarbakır','sur']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:07:11.852Z'::timestamptz,
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
    (select id from public.provinces where slug = 'diyarbakir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'diyarbakir' and d.slug = 'sur' limit 1),
    'Hasan Pasa Hani',
    'hasan-pasa-hani',
    'historical'::public.place_category,
    'SRID=4326;POINT(40.2374267 37.9127242)'::geography,
    'Hasan Pasa Hani, Sur tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','diyarbakır','sur']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:07:15.590Z'::timestamptz,
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
    (select id from public.provinces where slug = 'nevsehir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'nevsehir' and d.slug = 'goreme' limit 1),
    'Goreme',
    'goreme',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.8545451 38.6499774)'::geography,
    'Goreme, Goreme tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','nevşehir','goreme']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:07:20.355Z'::timestamptz,
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
    (select id from public.provinces where slug = 'nevsehir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'nevsehir' and d.slug = 'goreme' limit 1),
    'Goreme Acik Hava Muzesi',
    'goreme-acik-hava-muzesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.8451355 38.6396419)'::geography,
    'Goreme Acik Hava Muzesi, Goreme tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','nevşehir','goreme']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:07:25.069Z'::timestamptz,
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
    (select id from public.provinces where slug = 'nevsehir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'nevsehir' and d.slug = 'uchisar' limit 1),
    'Uchisar',
    'uchisar',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.8097463 38.6341306)'::geography,
    'Uchisar, Uchisar tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','nevşehir','uchisar']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:07:28.437Z'::timestamptz,
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
    (select id from public.provinces where slug = 'nevsehir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'nevsehir' and d.slug = 'uchisar' limit 1),
    'Uchisar Kalesi',
    'uchisar-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.805323 38.6304425)'::geography,
    'Uchisar Kalesi, Uchisar tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','nevşehir','uchisar']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:07:32.185Z'::timestamptz,
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
    (select id from public.provinces where slug = 'nevsehir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'nevsehir' and d.slug = 'derinkuyu' limit 1),
    'Derinkuyu',
    'derinkuyu',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.7336187 38.3743882)'::geography,
    'Derinkuyu, Derinkuyu tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','nevşehir','derinkuyu']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:07:34.083Z'::timestamptz,
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
    (select id from public.provinces where slug = 'nevsehir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'nevsehir' and d.slug = 'derinkuyu' limit 1),
    'Derinkuyu Yeralti Sehri',
    'derinkuyu-yeralti-sehri',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.7351222 38.3735761)'::geography,
    'Derinkuyu Yeralti Sehri, Derinkuyu tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','nevşehir','derinkuyu']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:07:36.069Z'::timestamptz,
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
    (select id from public.provinces where slug = 'nevsehir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'nevsehir' and d.slug = 'kaymakli' limit 1),
    'Kaymakli',
    'kaymakli',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.7524882 38.4599265)'::geography,
    'Kaymakli, Kaymakli tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','nevşehir','kaymakli']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:07:39.101Z'::timestamptz,
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
    (select id from public.provinces where slug = 'nevsehir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'nevsehir' and d.slug = 'kaymakli' limit 1),
    'Kaymakli Yeralti Sehri',
    'kaymakli-yeralti-sehri',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.7524882 38.4599265)'::geography,
    'Kaymakli Yeralti Sehri, Kaymakli tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','nevşehir','kaymakli']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:07:41.264Z'::timestamptz,
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
    (select id from public.provinces where slug = 'nevsehir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'nevsehir' and d.slug = 'avanos' limit 1),
    'Avanos',
    'avanos',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.8468663 38.7187371)'::geography,
    'Avanos, Avanos tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','nevşehir','avanos']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:07:43.689Z'::timestamptz,
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
    (select id from public.provinces where slug = 'nevsehir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'nevsehir' and d.slug = 'avanos' limit 1),
    'Ozkonak',
    'ozkonak',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.8395412 38.8132705)'::geography,
    'Ozkonak, Avanos tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','nevşehir','avanos']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:07:49.267Z'::timestamptz,
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
    (select id from public.provinces where slug = 'nevsehir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'nevsehir' and d.slug = 'urgup' limit 1),
    'Urgup',
    'urgup',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.9116025 38.6300508)'::geography,
    'Urgup, Urgup tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','nevşehir','urgup']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:07:51.671Z'::timestamptz,
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
    (select id from public.provinces where slug = 'nevsehir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'nevsehir' and d.slug = 'urgup' limit 1),
    'Uc Guzeller',
    'uc-guzeller',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.8903599 38.6354696)'::geography,
    'Uc Guzeller, Urgup tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','nevşehir','urgup']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:07:53.365Z'::timestamptz,
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
    (select id from public.provinces where slug = 'nevsehir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'nevsehir' and d.slug = 'urgup' limit 1),
    'Ortahisar',
    'ortahisar',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.865156 38.6214638)'::geography,
    'Ortahisar, Urgup tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','nevşehir','urgup']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:07:55.001Z'::timestamptz,
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
    (select id from public.provinces where slug = 'nevsehir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'nevsehir' and d.slug = 'urgup' limit 1),
    'Mustafapasa',
    'mustafapasa',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.8969158 38.5833959)'::geography,
    'Mustafapasa, Urgup tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','nevşehir','urgup']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:07:57.776Z'::timestamptz,
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
    (select id from public.provinces where slug = 'nevsehir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'nevsehir' and d.slug = 'hacibektas' limit 1),
    'Hacibektas',
    'hacibektas',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.5608817 38.9428835)'::geography,
    'Hacibektas, Hacibektas tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','nevşehir','hacibektas']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:07:59.498Z'::timestamptz,
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
    (select id from public.provinces where slug = 'nevsehir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'nevsehir' and d.slug = 'acigol' limit 1),
    'Acigol',
    'acigol',
    'nature'::public.place_category,
    'SRID=4326;POINT(34.6172761 38.5406469)'::geography,
    'Acigol, Acigol bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','nevşehir','acigol']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:08:04.998Z'::timestamptz,
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
    (select id from public.provinces where slug = 'aksaray' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'aksaray' and d.slug = 'guzelyurt' limit 1),
    'Ihlara Vadisi',
    'ihlara-vadisi',
    'nature'::public.place_category,
    'SRID=4326;POINT(34.3010469 38.2559485)'::geography,
    'Ihlara Vadisi, Guzelyurt bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','aksaray','guzelyurt']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:08:08.669Z'::timestamptz,
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
    (select id from public.provinces where slug = 'aksaray' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'aksaray' and d.slug = 'guzelyurt' limit 1),
    'Ihlara',
    'ihlara',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.3064664 38.2384492)'::geography,
    'Ihlara, Guzelyurt tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','aksaray','guzelyurt']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:08:10.449Z'::timestamptz,
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
    (select id from public.provinces where slug = 'aksaray' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'aksaray' and d.slug = 'merkez' limit 1),
    'Hasan Dagi',
    'hasan-dagi',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.1651126 38.1265274)'::geography,
    'Hasan Dagi, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','aksaray','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:08:15.175Z'::timestamptz,
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
    (select id from public.provinces where slug = 'trabzon' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'trabzon' and d.slug = 'macka' limit 1),
    'Sumela',
    'sumela',
    'historical'::public.place_category,
    'SRID=4326;POINT(39.6583668 40.6900948)'::geography,
    'Sumela, Macka tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','trabzon','macka']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:08:17.476Z'::timestamptz,
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
    (select id from public.provinces where slug = 'giresun' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'giresun' and d.slug = 'merkez' limit 1),
    'Giresun Adasi',
    'giresun-adasi',
    'beach'::public.place_category,
    'SRID=4326;POINT(38.4365584 40.9293597)'::geography,
    'Giresun Adasi, Merkez tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','giresun','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:08:25.733Z'::timestamptz,
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
    (select id from public.provinces where slug = 'giresun' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'giresun' and d.slug = 'tirebolu' limit 1),
    'Tirebolu Kalesi',
    'tirebolu-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(38.821191 41.0075494)'::geography,
    'Tirebolu Kalesi, Tirebolu tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','giresun','tirebolu']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:08:29.072Z'::timestamptz,
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
    (select id from public.provinces where slug = 'samsun' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'samsun' and d.slug = 'bafra' limit 1),
    'Kizilirmak Deltasi',
    'kizilirmak-deltasi',
    'historical'::public.place_category,
    'SRID=4326;POINT(36.0355242 41.6697721)'::geography,
    'Kizilirmak Deltasi, Bafra tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','samsun','bafra']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:08:33.791Z'::timestamptz,
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
    (select id from public.provinces where slug = 'samsun' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'samsun' and d.slug = 'bafra' limit 1),
    'Bafra',
    'bafra',
    'historical'::public.place_category,
    'SRID=4326;POINT(35.7609677 41.5448827)'::geography,
    'Bafra, Bafra tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','samsun','bafra']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:08:35.557Z'::timestamptz,
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
    (select id from public.provinces where slug = 'samsun' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'samsun' and d.slug = 'vezirkopru' limit 1),
    'Sahinkaya Kanyonu',
    'sahinkaya-kanyonu',
    'nature'::public.place_category,
    'SRID=4326;POINT(35.4057125 41.2707932)'::geography,
    'Sahinkaya Kanyonu, Vezirkopru bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','samsun','vezirkopru']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:08:37.285Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kastamonu' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'kastamonu' and d.slug = 'pinarbaşı' limit 1),
    'Valla Kanyonu',
    'valla-kanyonu',
    'nature'::public.place_category,
    'SRID=4326;POINT(33.0451819 41.7490085)'::geography,
    'Valla Kanyonu, Pinarbaşı bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','kastamonu','pinarbaşı']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:08:39.028Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kastamonu' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'kastamonu' and d.slug = 'merkez' limit 1),
    'Kastamonu Kalesi',
    'kastamonu-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(33.76968 41.3747689)'::geography,
    'Kastamonu Kalesi, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','kastamonu','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:08:44.807Z'::timestamptz,
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
    (select id from public.provinces where slug = 'sinop' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'sinop' and d.slug = 'merkez' limit 1),
    'Sinop Cezaevi',
    'sinop-cezaevi',
    'historical'::public.place_category,
    'SRID=4326;POINT(35.1424343 42.0246097)'::geography,
    'Sinop Cezaevi, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','sinop','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:08:48.159Z'::timestamptz,
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
    (select id from public.provinces where slug = 'sinop' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'sinop' and d.slug = 'merkez' limit 1),
    'Sinop Kalesi',
    'sinop-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(35.1508157 42.0246749)'::geography,
    'Sinop Kalesi, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','sinop','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:08:50.053Z'::timestamptz,
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
    (select id from public.provinces where slug = 'isparta' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'isparta' and d.slug = 'egirdir' limit 1),
    'Egirdir',
    'egirdir',
    'historical'::public.place_category,
    'SRID=4326;POINT(30.8500433 37.8744344)'::geography,
    'Egirdir, Egirdir tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','isparta','egirdir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:08:56.717Z'::timestamptz,
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
    (select id from public.provinces where slug = 'burdur' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'burdur' and d.slug = 'yesilova' limit 1),
    'Salda Golu',
    'salda-golu',
    'nature'::public.place_category,
    'SRID=4326;POINT(29.6816127 37.5475982)'::geography,
    'Salda Golu, Yesilova bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','burdur','yesilova']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:09:02.716Z'::timestamptz,
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
    (select id from public.provinces where slug = 'burdur' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'burdur' and d.slug = 'aglasun' limit 1),
    'Sagalassos',
    'sagalassos',
    'historical'::public.place_category,
    'SRID=4326;POINT(30.5176212 37.6753135)'::geography,
    'Sagalassos, Aglasun tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','burdur','aglasun']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:09:04.723Z'::timestamptz,
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
    (select id from public.provinces where slug = 'burdur' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'burdur' and d.slug = 'merkez' limit 1),
    'Insuyu Magarasi',
    'insuyu-magarasi',
    'nature'::public.place_category,
    'SRID=4326;POINT(30.3757774 37.6597429)'::geography,
    'Insuyu Magarasi, Merkez bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','burdur','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:09:06.478Z'::timestamptz,
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
    (select id from public.provinces where slug = 'erzurum' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'erzurum' and d.slug = 'palandoken' limit 1),
    'Palandoken',
    'palandoken',
    'historical'::public.place_category,
    'SRID=4326;POINT(41.2753321 39.8597575)'::geography,
    'Palandoken, Palandoken tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','erzurum','palandoken']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:09:08.171Z'::timestamptz,
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
    (select id from public.provinces where slug = 'erzurum' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'erzurum' and d.slug = 'palandoken' limit 1),
    'Palandoken Kayak Merkezi',
    'palandoken-kayak-merkezi',
    'historical'::public.place_category,
    'SRID=4326;POINT(41.2753321 39.8597575)'::geography,
    'Palandoken Kayak Merkezi, Palandoken tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','erzurum','palandoken']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:09:09.842Z'::timestamptz,
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
    (select id from public.provinces where slug = 'erzurum' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'erzurum' and d.slug = 'oltu' limit 1),
    'Oltu Kalesi',
    'oltu-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(41.9933196 40.5430845)'::geography,
    'Oltu Kalesi, Oltu tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','erzurum','oltu']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:09:11.705Z'::timestamptz,
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
    (select id from public.provinces where slug = 'erzurum' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'erzurum' and d.slug = 'uzundere' limit 1),
    'Tortum Selalesi',
    'tortum-selalesi',
    'nature'::public.place_category,
    'SRID=4326;POINT(41.6684361 40.6609123)'::geography,
    'Tortum Selalesi, Uzundere bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','erzurum','uzundere']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:09:13.534Z'::timestamptz,
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
    (select id from public.provinces where slug = 'erzurum' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'erzurum' and d.slug = 'uzundere' limit 1),
    'Tortum Golu',
    'tortum-golu',
    'nature'::public.place_category,
    'SRID=4326;POINT(41.6355516 40.6257651)'::geography,
    'Tortum Golu, Uzundere bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','erzurum','uzundere']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:09:15.429Z'::timestamptz,
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
    (select id from public.provinces where slug = 'balikesir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'balikesir' and d.slug = 'ayvalik' limit 1),
    'Seytan Sofrasi',
    'seytan-sofrasi',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.6429783 39.2887541)'::geography,
    'Seytan Sofrasi, Ayvalik tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','balıkesir','ayvalik']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:09:32.383Z'::timestamptz,
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
    (select id from public.provinces where slug = 'balikesir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'balikesir' and d.slug = 'edremit' limit 1),
    'Kaz Daglari',
    'kaz-daglari',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.7637243 39.672853)'::geography,
    'Kaz Daglari, Edremit tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','balıkesir','edremit']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:09:34.833Z'::timestamptz,
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
    (select id from public.provinces where slug = 'balikesir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'balikesir' and d.slug = 'bandirma' limit 1),
    'Manyas',
    'manyas',
    'historical'::public.place_category,
    'SRID=4326;POINT(28.1260891 40.1086941)'::geography,
    'Manyas, Bandirma tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','balıkesir','bandirma']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:09:39.480Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'adana' and d.slug = 'seyhan' limit 1),
    'Ulu Cami',
    'ulu-cami',
    'historical'::public.place_category,
    'SRID=4326;POINT(35.3309746 36.9848262)'::geography,
    'Ulu Cami, Seyhan tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','adana','seyhan']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:09:43.247Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'adana' and d.slug = 'seyhan' limit 1),
    'Tepebag',
    'tepebag',
    'viewpoint'::public.place_category,
    'SRID=4326;POINT(35.3274822 36.9880197)'::geography,
    'Tepebag, Seyhan civarinda manzara ve fotograf icin one cikan ikonik bir noktadir.',
    'sunset'::public.best_time,
    60,
    array['must-see','iconic','adana','seyhan']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:09:45.097Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'adana' and d.slug = 'kozan' limit 1),
    'Kozan Kalesi',
    'kozan-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(35.8087805 37.4414073)'::geography,
    'Kozan Kalesi, Kozan tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','adana','kozan']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:10:00.659Z'::timestamptz,
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
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'adana' and d.slug = 'karaisali' limit 1),
    'Karaisali',
    'karaisali',
    'historical'::public.place_category,
    'SRID=4326;POINT(35.0930942 37.2485731)'::geography,
    'Karaisali, Karaisali tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','adana','karaisali']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:10:04.050Z'::timestamptz,
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
    (select id from public.provinces where slug = 'afyonkarahisar' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'afyonkarahisar' and d.slug = 'merkez' limit 1),
    'Ulu Cami',
    'ulu-cami',
    'historical'::public.place_category,
    'SRID=4326;POINT(30.5295733 38.7550243)'::geography,
    'Ulu Cami, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','afyonkarahisar','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:10:09.180Z'::timestamptz,
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
    (select id from public.provinces where slug = 'amasya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'amasya' and d.slug = 'merkez' limit 1),
    'Amasya Kalesi',
    'amasya-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(35.8274515 40.6552114)'::geography,
    'Amasya Kalesi, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','amasya','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:10:25.967Z'::timestamptz,
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
    (select id from public.provinces where slug = 'amasya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'amasya' and d.slug = 'merkez' limit 1),
    'Kral Kaya Mezarlari',
    'kral-kaya-mezarlari',
    'historical'::public.place_category,
    'SRID=4326;POINT(35.829145 40.6529947)'::geography,
    'Kral Kaya Mezarlari, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','amasya','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:10:27.829Z'::timestamptz,
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
    (select id from public.provinces where slug = 'amasya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'amasya' and d.slug = 'merkez' limit 1),
    'Hazeranlar Konagi',
    'hazeranlar-konagi',
    'historical'::public.place_category,
    'SRID=4326;POINT(35.8297873 40.652291)'::geography,
    'Hazeranlar Konagi, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','amasya','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:10:30.139Z'::timestamptz,
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
    (select id from public.provinces where slug = 'amasya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'amasya' and d.slug = 'merkez' limit 1),
    'Yesilirmak',
    'yesilirmak',
    'historical'::public.place_category,
    'SRID=4326;POINT(35.8297903 40.6487853)'::geography,
    'Yesilirmak, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','amasya','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:10:32.371Z'::timestamptz,
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
    (select id from public.provinces where slug = 'amasya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'amasya' and d.slug = 'tasova' limit 1),
    'Tasova',
    'tasova',
    'historical'::public.place_category,
    'SRID=4326;POINT(36.3501351 40.813384)'::geography,
    'Tasova, Tasova tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','amasya','tasova']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:10:36.655Z'::timestamptz,
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
    (select id from public.provinces where slug = 'ardahan' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'ardahan' and d.slug = 'merkez' limit 1),
    'Ardahan Kalesi',
    'ardahan-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(42.7037085 41.1180768)'::geography,
    'Ardahan Kalesi, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','ardahan','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:10:38.525Z'::timestamptz,
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
    (select id from public.provinces where slug = 'ardahan' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'ardahan' and d.slug = 'cildir' limit 1),
    'Cildir Golu',
    'cildir-golu',
    'nature'::public.place_category,
    'SRID=4326;POINT(43.1293097 41.1045256)'::geography,
    'Cildir Golu, Cildir bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','ardahan','cildir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:10:40.280Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bartin' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'bartin' and d.slug = 'amasra' limit 1),
    'Amasra Kalesi',
    'amasra-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(32.3872852 41.7497294)'::geography,
    'Amasra Kalesi, Amasra tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','bartın','amasra']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:10:45.245Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bartin' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'bartin' and d.slug = 'amasra' limit 1),
    'Amasra',
    'amasra',
    'historical'::public.place_category,
    'SRID=4326;POINT(32.3838002 41.7531401)'::geography,
    'Amasra, Amasra tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','bartın','amasra']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:10:47.000Z'::timestamptz,
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
    (select id from public.provinces where slug = 'batman' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'batman' and d.slug = 'hasankeyf' limit 1),
    'Hasankeyf',
    'hasankeyf',
    'historical'::public.place_category,
    'SRID=4326;POINT(41.4088911 37.7106239)'::geography,
    'Hasankeyf, Hasankeyf tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','batman','hasankeyf']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:10:52.066Z'::timestamptz,
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
    (select id from public.provinces where slug = 'batman' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'batman' and d.slug = 'hasankeyf' limit 1),
    'Eski Hasankeyf',
    'eski-hasankeyf',
    'historical'::public.place_category,
    'SRID=4326;POINT(41.4149449 37.712987)'::geography,
    'Eski Hasankeyf, Hasankeyf tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','batman','hasankeyf']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:10:54.036Z'::timestamptz,
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
    (select id from public.provinces where slug = 'batman' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'batman' and d.slug = 'merkez' limit 1),
    'Batman',
    'batman',
    'historical'::public.place_category,
    'SRID=4326;POINT(41.1226819 37.8785813)'::geography,
    'Batman, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','batman','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:10:56.096Z'::timestamptz,
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
    (select id from public.provinces where slug = 'batman' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'batman' and d.slug = 'besiri' limit 1),
    'Besiri',
    'besiri',
    'historical'::public.place_category,
    'SRID=4326;POINT(41.3314384 37.9643114)'::geography,
    'Besiri, Besiri tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','batman','besiri']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:10:57.860Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bayburt' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'bayburt' and d.slug = 'merkez' limit 1),
    'Bayburt Kalesi',
    'bayburt-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(40.2297903 40.2634463)'::geography,
    'Bayburt Kalesi, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','bayburt','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:10:59.798Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bayburt' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'bayburt' and d.slug = 'merkez' limit 1),
    'Bayburt',
    'bayburt',
    'historical'::public.place_category,
    'SRID=4326;POINT(40.2096782 40.259129)'::geography,
    'Bayburt, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','bayburt','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:11:01.777Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bayburt' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'bayburt' and d.slug = 'aydintepe' limit 1),
    'Aydintepe',
    'aydintepe',
    'viewpoint'::public.place_category,
    'SRID=4326;POINT(40.1303746 40.3713797)'::geography,
    'Aydintepe, Aydintepe civarinda manzara ve fotograf icin one cikan ikonik bir noktadir.',
    'sunset'::public.best_time,
    60,
    array['must-see','iconic','bayburt','aydintepe']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:11:03.475Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bayburt' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'bayburt' and d.slug = 'demirozu' limit 1),
    'Demirozu',
    'demirozu',
    'historical'::public.place_category,
    'SRID=4326;POINT(39.8994366 40.1300682)'::geography,
    'Demirozu, Demirozu tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','bayburt','demirozu']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:11:05.832Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bilecik' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'bilecik' and d.slug = 'sogut' limit 1),
    'Ertugrul Gazi Turbesi',
    'ertugrul-gazi-turbesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(30.1792958 40.0254817)'::geography,
    'Ertugrul Gazi Turbesi, Sogut tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','bilecik','sogut']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:11:09.285Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bilecik' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'bilecik' and d.slug = 'bozuyuk' limit 1),
    'Bozuyuk',
    'bozuyuk',
    'historical'::public.place_category,
    'SRID=4326;POINT(30.0372781 39.9042599)'::geography,
    'Bozuyuk, Bozuyuk tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','bilecik','bozuyuk']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:11:11.261Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bilecik' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'bilecik' and d.slug = 'golpazari' limit 1),
    'Golpazari',
    'golpazari',
    'nature'::public.place_category,
    'SRID=4326;POINT(30.0682275 40.2363648)'::geography,
    'Golpazari, Golpazari bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','bilecik','golpazari']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:11:13.475Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bingol' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'bingol' and d.slug = 'merkez' limit 1),
    'Bingol',
    'bingol',
    'nature'::public.place_category,
    'SRID=4326;POINT(40.557119 38.908062)'::geography,
    'Bingol, Merkez bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','bingöl','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:11:15.358Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bingol' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'bingol' and d.slug = 'genc' limit 1),
    'Genc',
    'genc',
    'historical'::public.place_category,
    'SRID=4326;POINT(40.5576394 38.7518473)'::geography,
    'Genc, Genc tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','bingöl','genc']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:11:18.898Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bitlis' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'bitlis' and d.slug = 'ahlat' limit 1),
    'Selcuklu Mezarligi',
    'selcuklu-mezarligi',
    'historical'::public.place_category,
    'SRID=4326;POINT(42.4580318 38.7420931)'::geography,
    'Selcuklu Mezarligi, Ahlat tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','bitlis','ahlat']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:11:24.813Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bitlis' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'bitlis' and d.slug = 'merkez' limit 1),
    'Bitlis Kalesi',
    'bitlis-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(42.1077212 38.4016884)'::geography,
    'Bitlis Kalesi, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','bitlis','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:11:37.699Z'::timestamptz,
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
    (select id from public.provinces where slug = 'bitlis' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'bitlis' and d.slug = 'adilcevaz' limit 1),
    'Adilcevaz Kalesi',
    'adilcevaz-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(42.7291426 38.8013639)'::geography,
    'Adilcevaz Kalesi, Adilcevaz tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','bitlis','adilcevaz']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:11:39.382Z'::timestamptz,
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
    (select id from public.provinces where slug = 'cankiri' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'cankiri' and d.slug = 'merkez' limit 1),
    'Tuz Magarasi',
    'tuz-magarasi',
    'nature'::public.place_category,
    'SRID=4326;POINT(33.7600591 40.54258)'::geography,
    'Tuz Magarasi, Merkez bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','çankırı','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:11:41.089Z'::timestamptz,
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
    (select id from public.provinces where slug = 'cankiri' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'cankiri' and d.slug = 'merkez' limit 1),
    'Cankiri Kalesi',
    'cankiri-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(33.6165658 40.6081917)'::geography,
    'Cankiri Kalesi, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','çankırı','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:11:42.818Z'::timestamptz,
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
    (select id from public.provinces where slug = 'corum' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'corum' and d.slug = 'bogazkale' limit 1),
    'Hattusas',
    'hattusas',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.6197357 40.0222167)'::geography,
    'Hattusas, Bogazkale tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','çorum','bogazkale']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:11:48.290Z'::timestamptz,
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
    (select id from public.provinces where slug = 'corum' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'corum' and d.slug = 'bogazkale' limit 1),
    'Hattusa',
    'hattusa',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.6197357 40.0222167)'::geography,
    'Hattusa, Bogazkale tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','çorum','bogazkale']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:11:50.253Z'::timestamptz,
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
    (select id from public.provinces where slug = 'corum' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'corum' and d.slug = 'bogazkale' limit 1),
    'Bogazkoy',
    'bogazkoy',
    'beach'::public.place_category,
    'SRID=4326;POINT(34.6183376 40.024139)'::geography,
    'Bogazkoy, Bogazkale tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','çorum','bogazkale']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:11:53.528Z'::timestamptz,
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
    (select id from public.provinces where slug = 'corum' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'corum' and d.slug = 'alaca' limit 1),
    'Alacahoyuk',
    'alacahoyuk',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.6950961 40.2345193)'::geography,
    'Alacahoyuk, Alaca tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','çorum','alaca']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:11:55.442Z'::timestamptz,
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
    (select id from public.provinces where slug = 'corum' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'corum' and d.slug = 'merkez' limit 1),
    'Corum',
    'corum',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.9622731 40.5722705)'::geography,
    'Corum, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','çorum','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:11:57.251Z'::timestamptz,
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
    (select id from public.provinces where slug = 'corum' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'corum' and d.slug = 'iskilip' limit 1),
    'Iskilip',
    'iskilip',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.4733557 40.7334731)'::geography,
    'Iskilip, Iskilip tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','çorum','iskilip']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:11:59.575Z'::timestamptz,
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
    (select id from public.provinces where slug = 'duzce' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'duzce' and d.slug = 'merkez' limit 1),
    'Duzce',
    'duzce',
    'historical'::public.place_category,
    'SRID=4326;POINT(31.090859 40.848888)'::geography,
    'Duzce, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','düzce','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:12:01.987Z'::timestamptz,
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
    (select id from public.provinces where slug = 'duzce' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'duzce' and d.slug = 'akcakoca' limit 1),
    'Akcakoca',
    'akcakoca',
    'historical'::public.place_category,
    'SRID=4326;POINT(31.1286547 41.0846311)'::geography,
    'Akcakoca, Akcakoca tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','düzce','akcakoca']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:12:03.849Z'::timestamptz,
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
    (select id from public.provinces where slug = 'duzce' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'duzce' and d.slug = 'golyaka' limit 1),
    'Golyaka',
    'golyaka',
    'nature'::public.place_category,
    'SRID=4326;POINT(31.0251209 40.7859353)'::geography,
    'Golyaka, Golyaka bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','düzce','golyaka']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:12:07.532Z'::timestamptz,
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
    (select id from public.provinces where slug = 'edirne' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'edirne' and d.slug = 'merkez' limit 1),
    'Selimiye Camii',
    'selimiye-camii',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.5593409 41.6781393)'::geography,
    'Selimiye Camii, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','edirne','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:12:09.789Z'::timestamptz,
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
    (select id from public.provinces where slug = 'edirne' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'edirne' and d.slug = 'merkez' limit 1),
    'Kirkpinar',
    'kirkpinar',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.5884813 41.6598425)'::geography,
    'Kirkpinar, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','edirne','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:12:11.734Z'::timestamptz,
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
    (select id from public.provinces where slug = 'edirne' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'edirne' and d.slug = 'merkez' limit 1),
    'Edirne Kalesi',
    'edirne-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.5531736 41.6720522)'::geography,
    'Edirne Kalesi, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','edirne','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:12:13.532Z'::timestamptz,
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
    (select id from public.provinces where slug = 'edirne' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'edirne' and d.slug = 'merkez' limit 1),
    'Eski Cami',
    'eski-cami',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.5558544 41.6766422)'::geography,
    'Eski Cami, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','edirne','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:12:15.803Z'::timestamptz,
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
    (select id from public.provinces where slug = 'edirne' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'edirne' and d.slug = 'merkez' limit 1),
    'Uc Serefeli Cami',
    'uc-serefeli-cami',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.5535233 41.6779635)'::geography,
    'Uc Serefeli Cami, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','edirne','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:12:22.432Z'::timestamptz,
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
    (select id from public.provinces where slug = 'edirne' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'edirne' and d.slug = 'uzunkopru' limit 1),
    'Uzunkopru',
    'uzunkopru',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.689612 41.2960389)'::geography,
    'Uzunkopru, Uzunkopru tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','edirne','uzunkopru']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:12:24.206Z'::timestamptz,
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
    (select id from public.provinces where slug = 'edirne' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'edirne' and d.slug = 'ipsala' limit 1),
    'Ipsala',
    'ipsala',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.375894 40.9255105)'::geography,
    'Ipsala, Ipsala tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','edirne','ipsala']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:12:26.005Z'::timestamptz,
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
    (select id from public.provinces where slug = 'edirne' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'edirne' and d.slug = 'enez' limit 1),
    'Enez',
    'enez',
    'historical'::public.place_category,
    'SRID=4326;POINT(26.0673872 40.6584534)'::geography,
    'Enez, Enez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','edirne','enez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:12:29.490Z'::timestamptz,
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
    (select id from public.provinces where slug = 'elazig' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'elazig' and d.slug = 'harput' limit 1),
    'Buzluk Magarasi',
    'buzluk-magarasi',
    'nature'::public.place_category,
    'SRID=4326;POINT(39.2827641 38.7361054)'::geography,
    'Buzluk Magarasi, Harput bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','elazığ','harput']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:12:33.945Z'::timestamptz,
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
    (select id from public.provinces where slug = 'elazig' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'elazig' and d.slug = 'merkez' limit 1),
    'Elazig',
    'elazig',
    'historical'::public.place_category,
    'SRID=4326;POINT(39.2227818 38.6648383)'::geography,
    'Elazig, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','elazığ','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:12:36.291Z'::timestamptz,
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
    (select id from public.provinces where slug = 'erzincan' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'erzincan' and d.slug = 'merkez' limit 1),
    'Erzincan',
    'erzincan',
    'historical'::public.place_category,
    'SRID=4326;POINT(39.4931041 39.7336676)'::geography,
    'Erzincan, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','erzincan','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:12:52.770Z'::timestamptz,
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
    (select id from public.provinces where slug = 'erzincan' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'erzincan' and d.slug = 'uzumlu' limit 1),
    'Altintepe',
    'altintepe',
    'viewpoint'::public.place_category,
    'SRID=4326;POINT(39.6466636 39.696422)'::geography,
    'Altintepe, Uzumlu civarinda manzara ve fotograf icin one cikan ikonik bir noktadir.',
    'sunset'::public.best_time,
    60,
    array['must-see','iconic','erzincan','uzumlu']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:12:57.748Z'::timestamptz,
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
    (select id from public.provinces where slug = 'erzincan' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'erzincan' and d.slug = 'kemaliye' limit 1),
    'Kemaliye',
    'kemaliye',
    'historical'::public.place_category,
    'SRID=4326;POINT(38.3470544 39.3678849)'::geography,
    'Kemaliye, Kemaliye tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','erzincan','kemaliye']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:12:59.531Z'::timestamptz,
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
    (select id from public.provinces where slug = 'erzincan' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'erzincan' and d.slug = 'kemaliye' limit 1),
    'Karanlik Kanyon',
    'karanlik-kanyon',
    'nature'::public.place_category,
    'SRID=4326;POINT(38.4881041 39.2847725)'::geography,
    'Karanlik Kanyon, Kemaliye bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','erzincan','kemaliye']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:13:01.203Z'::timestamptz,
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
    (select id from public.provinces where slug = 'erzincan' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'erzincan' and d.slug = 'kemaliye' limit 1),
    'Egin',
    'egin',
    'historical'::public.place_category,
    'SRID=4326;POINT(38.4881041 39.2847725)'::geography,
    'Egin, Kemaliye tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','erzincan','kemaliye']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:13:04.361Z'::timestamptz,
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
    (select id from public.provinces where slug = 'erzincan' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'erzincan' and d.slug = 'ilic' limit 1),
    'Karanlik Kanyon',
    'karanlik-kanyon',
    'nature'::public.place_category,
    'SRID=4326;POINT(38.4881041 39.2847725)'::geography,
    'Karanlik Kanyon, Ilic bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','erzincan','ilic']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:13:06.134Z'::timestamptz,
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
    (select id from public.provinces where slug = 'erzincan' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'erzincan' and d.slug = 'ilic' limit 1),
    'Ilic',
    'ilic',
    'historical'::public.place_category,
    'SRID=4326;POINT(38.5565288 39.4721719)'::geography,
    'Ilic, Ilic tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','erzincan','ilic']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:13:07.990Z'::timestamptz,
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
    (select id from public.provinces where slug = 'erzincan' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'erzincan' and d.slug = 'kemah' limit 1),
    'Kemah Kalesi',
    'kemah-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(39.038102 39.6043679)'::geography,
    'Kemah Kalesi, Kemah tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','erzincan','kemah']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:13:09.897Z'::timestamptz,
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
    (select id from public.provinces where slug = 'erzincan' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'erzincan' and d.slug = 'kemah' limit 1),
    'Sultan Melik Turbesi',
    'sultan-melik-turbesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(39.0328459 39.6082313)'::geography,
    'Sultan Melik Turbesi, Kemah tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','erzincan','kemah']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:13:11.519Z'::timestamptz,
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
    (select id from public.provinces where slug = 'erzincan' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'erzincan' and d.slug = 'refahiye' limit 1),
    'Refahiye',
    'refahiye',
    'historical'::public.place_category,
    'SRID=4326;POINT(38.7812464 39.9077555)'::geography,
    'Refahiye, Refahiye tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','erzincan','refahiye']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:13:14.695Z'::timestamptz,
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
    (select id from public.provinces where slug = 'eskisehir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'eskisehir' and d.slug = 'odunpazari' limit 1),
    'Odunpazari',
    'odunpazari',
    'historical'::public.place_category,
    'SRID=4326;POINT(30.5269162 39.7589279)'::geography,
    'Odunpazari, Odunpazari tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','eskişehir','odunpazari']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:13:16.679Z'::timestamptz,
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
    (select id from public.provinces where slug = 'eskisehir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'eskisehir' and d.slug = 'odunpazari' limit 1),
    'Porsuk Cayi',
    'porsuk-cayi',
    'historical'::public.place_category,
    'SRID=4326;POINT(30.6481587 39.7612114)'::geography,
    'Porsuk Cayi, Odunpazari tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','eskişehir','odunpazari']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:13:18.592Z'::timestamptz,
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
    (select id from public.provinces where slug = 'eskisehir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'eskisehir' and d.slug = 'merkez' limit 1),
    'Eskisehir',
    'eskisehir',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.9788076 40.143438)'::geography,
    'Eskisehir, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','eskişehir','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:13:22.499Z'::timestamptz,
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
    (select id from public.provinces where slug = 'eskisehir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'eskisehir' and d.slug = 'sivrihisar' limit 1),
    'Nasreddin Hoca',
    'nasreddin-hoca',
    'historical'::public.place_category,
    'SRID=4326;POINT(31.659498 39.517113)'::geography,
    'Nasreddin Hoca, Sivrihisar tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','eskişehir','sivrihisar']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:13:24.298Z'::timestamptz,
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
    (select id from public.provinces where slug = 'eskisehir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'eskisehir' and d.slug = 'sivrihisar' limit 1),
    'Sivrihisar',
    'sivrihisar',
    'historical'::public.place_category,
    'SRID=4326;POINT(31.2671905 39.4855493)'::geography,
    'Sivrihisar, Sivrihisar tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','eskişehir','sivrihisar']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:13:26.035Z'::timestamptz,
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
    (select id from public.provinces where slug = 'gumushane' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'gumushane' and d.slug = 'kelkit' limit 1),
    'Kelkit',
    'kelkit',
    'historical'::public.place_category,
    'SRID=4326;POINT(39.4369929 40.1244435)'::geography,
    'Kelkit, Kelkit tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','gümüşhane','kelkit']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:13:34.130Z'::timestamptz,
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
    (select id from public.provinces where slug = 'hakkari' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'hakkari' and d.slug = 'merkez' limit 1),
    'Hakkari',
    'hakkari',
    'historical'::public.place_category,
    'SRID=4326;POINT(43.7370378 37.5745342)'::geography,
    'Hakkari, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','hakkari','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:13:41.119Z'::timestamptz,
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
    (select id from public.provinces where slug = 'igdir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'igdir' and d.slug = 'merkez' limit 1),
    'Agri Dagi',
    'agri-dagi',
    'historical'::public.place_category,
    'SRID=4326;POINT(44.2983964 39.7019346)'::geography,
    'Agri Dagi, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','iğdır','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:13:46.659Z'::timestamptz,
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
    (select id from public.provinces where slug = 'igdir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'igdir' and d.slug = 'aralik' limit 1),
    'Aralik',
    'aralik',
    'historical'::public.place_category,
    'SRID=4326;POINT(44.5155973 39.8650781)'::geography,
    'Aralik, Aralik tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','iğdır','aralik']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:13:51.931Z'::timestamptz,
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
    (select id from public.provinces where slug = 'igdir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'igdir' and d.slug = 'tuzluca' limit 1),
    'Tuzluca',
    'tuzluca',
    'historical'::public.place_category,
    'SRID=4326;POINT(43.6687817 40.0492563)'::geography,
    'Tuzluca, Tuzluca tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','iğdır','tuzluca']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:13:53.704Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kahramanmaras' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'kahramanmaras' and d.slug = 'andirin' limit 1),
    'Andirin',
    'andirin',
    'historical'::public.place_category,
    'SRID=4326;POINT(36.2968758 37.4289371)'::geography,
    'Andirin, Andirin tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','kahramanmaraş','andirin']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:14:00.175Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kahramanmaras' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'kahramanmaras' and d.slug = 'afsin' limit 1),
    'Afsin',
    'afsin',
    'historical'::public.place_category,
    'SRID=4326;POINT(36.9243757 38.183381)'::geography,
    'Afsin, Afsin tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','kahramanmaraş','afsin']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:14:02.775Z'::timestamptz,
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
    (select id from public.provinces where slug = 'karaman' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'karaman' and d.slug = 'merkez' limit 1),
    'Karaman Kalesi',
    'karaman-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(33.2064648 37.1820307)'::geography,
    'Karaman Kalesi, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','karaman','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:14:07.513Z'::timestamptz,
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
    (select id from public.provinces where slug = 'karaman' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'karaman' and d.slug = 'merkez' limit 1),
    'Binbirkilise',
    'binbirkilise',
    'historical'::public.place_category,
    'SRID=4326;POINT(33.1674402 37.4384479)'::geography,
    'Binbirkilise, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','karaman','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:14:09.271Z'::timestamptz,
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
    (select id from public.provinces where slug = 'karaman' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'karaman' and d.slug = 'ermenek' limit 1),
    'Goksu',
    'goksu',
    'historical'::public.place_category,
    'SRID=4326;POINT(32.8874832 36.638724)'::geography,
    'Goksu, Ermenek tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','karaman','ermenek']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:14:12.578Z'::timestamptz,
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
    (select id from public.provinces where slug = 'karaman' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'karaman' and d.slug = 'ayranci' limit 1),
    'Ayranci',
    'ayranci',
    'historical'::public.place_category,
    'SRID=4326;POINT(33.6662614 37.3710613)'::geography,
    'Ayranci, Ayranci tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','karaman','ayranci']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:14:14.780Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kirikkale' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'kirikkale' and d.slug = 'merkez' limit 1),
    'Kirikkale',
    'kirikkale',
    'historical'::public.place_category,
    'SRID=4326;POINT(33.5058536 39.8410483)'::geography,
    'Kirikkale, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','kırıkkale','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:14:22.418Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kirikkale' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'kirikkale' and d.slug = 'merkez' limit 1),
    'Keskin',
    'keskin',
    'historical'::public.place_category,
    'SRID=4326;POINT(33.531453 39.8453611)'::geography,
    'Keskin, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','kırıkkale','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:14:24.607Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kirikkale' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'kirikkale' and d.slug = 'delice' limit 1),
    'Delice',
    'delice',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.030361 39.9436773)'::geography,
    'Delice, Delice tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','kırıkkale','delice']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:14:26.298Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kirklareli' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'kirklareli' and d.slug = 'igneada' limit 1),
    'Igneada',
    'igneada',
    'beach'::public.place_category,
    'SRID=4326;POINT(27.9872803 41.8773668)'::geography,
    'Igneada, Igneada tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','kırklareli','igneada']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:14:27.941Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kirklareli' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'kirklareli' and d.slug = 'luleburgaz' limit 1),
    'Luleburgaz',
    'luleburgaz',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.3325243 41.3554209)'::geography,
    'Luleburgaz, Luleburgaz tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','kırklareli','luleburgaz']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:14:31.139Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kirsehir' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'kirsehir' and d.slug = 'kaman' limit 1),
    'Kaman Kalehoyuk',
    'kaman-kalehoyuk',
    'historical'::public.place_category,
    'SRID=4326;POINT(33.7866664 39.3625662)'::geography,
    'Kaman Kalehoyuk, Kaman tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','kırşehir','kaman']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:14:41.709Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kocaeli' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'kocaeli' and d.slug = 'kartepe' limit 1),
    'Kartepe Kayak',
    'kartepe-kayak',
    'viewpoint'::public.place_category,
    'SRID=4326;POINT(30.0958648 40.6509201)'::geography,
    'Kartepe Kayak, Kartepe civarinda manzara ve fotograf icin one cikan ikonik bir noktadir.',
    'sunset'::public.best_time,
    60,
    array['must-see','iconic','kocaeli','kartepe']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:14:48.603Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kocaeli' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'kocaeli' and d.slug = 'golcuk' limit 1),
    'Golcuk',
    'golcuk',
    'nature'::public.place_category,
    'SRID=4326;POINT(29.8115181 40.723839)'::geography,
    'Golcuk, Golcuk bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','kocaeli','golcuk']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:14:51.898Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kocaeli' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'kocaeli' and d.slug = 'kandira' limit 1),
    'Kandira',
    'kandira',
    'historical'::public.place_category,
    'SRID=4326;POINT(30.153064 41.0706201)'::geography,
    'Kandira, Kandira tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','kocaeli','kandira']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:14:53.772Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kutahya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'kutahya' and d.slug = 'cavdarhisar' limit 1),
    'Aizanoi',
    'aizanoi',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.6096562 39.2011197)'::geography,
    'Aizanoi, Cavdarhisar tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','kütahya','cavdarhisar']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:14:55.559Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kutahya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'kutahya' and d.slug = 'merkez' limit 1),
    'Kutahya Kalesi',
    'kutahya-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.9712304 39.4191107)'::geography,
    'Kutahya Kalesi, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','kütahya','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:14:59.114Z'::timestamptz,
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
    (select id from public.provinces where slug = 'kutahya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'kutahya' and d.slug = 'gediz' limit 1),
    'Gediz',
    'gediz',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.3588466 38.9653797)'::geography,
    'Gediz, Gediz tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','kütahya','gediz']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:15:03.192Z'::timestamptz,
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
    (select id from public.provinces where slug = 'malatya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'malatya' and d.slug = 'battalgazi' limit 1),
    'Battalgazi',
    'battalgazi',
    'historical'::public.place_category,
    'SRID=4326;POINT(38.3698881 38.4335031)'::geography,
    'Battalgazi, Battalgazi tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','malatya','battalgazi']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:15:10.775Z'::timestamptz,
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
    (select id from public.provinces where slug = 'malatya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'malatya' and d.slug = 'battalgazi' limit 1),
    'Arslantepe Hoyugu',
    'arslantepe-hoyugu',
    'viewpoint'::public.place_category,
    'SRID=4326;POINT(38.3612351 38.38214)'::geography,
    'Arslantepe Hoyugu, Battalgazi civarinda manzara ve fotograf icin one cikan ikonik bir noktadir.',
    'sunset'::public.best_time,
    60,
    array['must-see','iconic','malatya','battalgazi']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:15:12.492Z'::timestamptz,
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
    (select id from public.provinces where slug = 'malatya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'malatya' and d.slug = 'dogansehir' limit 1),
    'Dogansehir',
    'dogansehir',
    'historical'::public.place_category,
    'SRID=4326;POINT(37.874647 38.089293)'::geography,
    'Dogansehir, Dogansehir tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','malatya','dogansehir']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:15:14.812Z'::timestamptz,
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
    (select id from public.provinces where slug = 'malatya' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'malatya' and d.slug = 'akcadag' limit 1),
    'Akcadag',
    'akcadag',
    'beach'::public.place_category,
    'SRID=4326;POINT(38.0444287 38.2908984)'::geography,
    'Akcadag, Akcadag tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','malatya','akcadag']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:15:16.564Z'::timestamptz,
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
    (select id from public.provinces where slug = 'manisa' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'manisa' and d.slug = 'turgutlu' limit 1),
    'Turgutlu',
    'turgutlu',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.7071726 38.5099987)'::geography,
    'Turgutlu, Turgutlu tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','manisa','turgutlu']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:15:22.898Z'::timestamptz,
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
    (select id from public.provinces where slug = 'manisa' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'manisa' and d.slug = 'akhisar' limit 1),
    'Akhisar',
    'akhisar',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.7905314 38.9080572)'::geography,
    'Akhisar, Akhisar tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','manisa','akhisar']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:15:24.829Z'::timestamptz,
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
    (select id from public.provinces where slug = 'manisa' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'manisa' and d.slug = 'golmarmara' limit 1),
    'Golmarmara',
    'golmarmara',
    'nature'::public.place_category,
    'SRID=4326;POINT(27.9883096 38.6479853)'::geography,
    'Golmarmara, Golmarmara bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','manisa','golmarmara']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:15:26.642Z'::timestamptz,
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
    (select id from public.provinces where slug = 'mus' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mus' and d.slug = 'malazgirt' limit 1),
    'Malazgirt',
    'malazgirt',
    'historical'::public.place_category,
    'SRID=4326;POINT(42.5119814 39.1393805)'::geography,
    'Malazgirt, Malazgirt tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muş','malazgirt']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:15:30.319Z'::timestamptz,
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
    (select id from public.provinces where slug = 'mus' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mus' and d.slug = 'malazgirt' limit 1),
    'Malazgirt Meydan Muharebesi',
    'malazgirt-meydan-muharebesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(42.5119814 39.1393805)'::geography,
    'Malazgirt Meydan Muharebesi, Malazgirt tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muş','malazgirt']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:15:32.091Z'::timestamptz,
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
    (select id from public.provinces where slug = 'mus' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mus' and d.slug = 'merkez' limit 1),
    'Mus Ovasi',
    'mus-ovasi',
    'historical'::public.place_category,
    'SRID=4326;POINT(41.5722655 38.7824579)'::geography,
    'Mus Ovasi, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muş','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:15:33.792Z'::timestamptz,
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
    (select id from public.provinces where slug = 'mus' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'mus' and d.slug = 'varto' limit 1),
    'Varto',
    'varto',
    'historical'::public.place_category,
    'SRID=4326;POINT(41.856695 39.0772567)'::geography,
    'Varto, Varto tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','muş','varto']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:15:35.612Z'::timestamptz,
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
    (select id from public.provinces where slug = 'nigde' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'nigde' and d.slug = 'merkez' limit 1),
    'Nigde Kalesi',
    'nigde-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.6794378 37.9683391)'::geography,
    'Nigde Kalesi, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','niğde','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:15:37.773Z'::timestamptz,
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
    (select id from public.provinces where slug = 'nigde' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'nigde' and d.slug = 'camardi' limit 1),
    'Aladaglar',
    'aladaglar',
    'beach'::public.place_category,
    'SRID=4326;POINT(35.151394 37.836758)'::geography,
    'Aladaglar, Camardi tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','niğde','camardi']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:15:47.547Z'::timestamptz,
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
    (select id from public.provinces where slug = 'ordu' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'ordu' and d.slug = 'merkez' limit 1),
    'Ordu',
    'ordu',
    'historical'::public.place_category,
    'SRID=4326;POINT(30.5435843 38.7592871)'::geography,
    'Ordu, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','ordu','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:15:50.821Z'::timestamptz,
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
    (select id from public.provinces where slug = 'ordu' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'ordu' and d.slug = 'persembe' limit 1),
    'Persembe Yaylasi',
    'persembe-yaylasi',
    'historical'::public.place_category,
    'SRID=4326;POINT(37.2982266 40.6265867)'::geography,
    'Persembe Yaylasi, Persembe tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','ordu','persembe']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:15:52.551Z'::timestamptz,
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
    (select id from public.provinces where slug = 'ordu' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'ordu' and d.slug = 'persembe' limit 1),
    'Camburnu',
    'camburnu',
    'historical'::public.place_category,
    'SRID=4326;POINT(37.7754817 41.1125418)'::geography,
    'Camburnu, Persembe tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','ordu','persembe']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:15:54.347Z'::timestamptz,
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
    (select id from public.provinces where slug = 'ordu' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'ordu' and d.slug = 'fatsa' limit 1),
    'Fatsa',
    'fatsa',
    'historical'::public.place_category,
    'SRID=4326;POINT(37.510403 41.025443)'::geography,
    'Fatsa, Fatsa tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','ordu','fatsa']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:15:57.626Z'::timestamptz,
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
    (select id from public.provinces where slug = 'osmaniye' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'osmaniye' and d.slug = 'kadirli' limit 1),
    'Karatepe',
    'karatepe',
    'viewpoint'::public.place_category,
    'SRID=4326;POINT(36.2537475 37.2958505)'::geography,
    'Karatepe, Kadirli civarinda manzara ve fotograf icin one cikan ikonik bir noktadir.',
    'sunset'::public.best_time,
    60,
    array['must-see','iconic','osmaniye','kadirli']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:16:00.747Z'::timestamptz,
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
    (select id from public.provinces where slug = 'sivas' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'sivas' and d.slug = 'divrigi' limit 1),
    'Divrigi Ulu Camii',
    'divrigi-ulu-camii',
    'historical'::public.place_category,
    'SRID=4326;POINT(38.1219282 39.3713625)'::geography,
    'Divrigi Ulu Camii, Divrigi tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','sivas','divrigi']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:16:06.513Z'::timestamptz,
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
    (select id from public.provinces where slug = 'sivas' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'sivas' and d.slug = 'divrigi' limit 1),
    'Divrigi',
    'divrigi',
    'historical'::public.place_category,
    'SRID=4326;POINT(38.1155364 39.3711727)'::geography,
    'Divrigi, Divrigi tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','sivas','divrigi']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:16:08.880Z'::timestamptz,
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
    (select id from public.provinces where slug = 'sivas' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'sivas' and d.slug = 'kangal' limit 1),
    'Kangal',
    'kangal',
    'historical'::public.place_category,
    'SRID=4326;POINT(37.4508649 39.2760303)'::geography,
    'Kangal, Kangal tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','sivas','kangal']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:16:12.113Z'::timestamptz,
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
    (select id from public.provinces where slug = 'sivas' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'sivas' and d.slug = 'merkez' limit 1),
    'Cifte Minare',
    'cifte-minare',
    'historical'::public.place_category,
    'SRID=4326;POINT(37.0142075 39.7481049)'::geography,
    'Cifte Minare, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','sivas','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:16:15.465Z'::timestamptz,
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
    (select id from public.provinces where slug = 'sivas' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'sivas' and d.slug = 'zara' limit 1),
    'Zara',
    'zara',
    'historical'::public.place_category,
    'SRID=4326;POINT(37.7619019 39.898474)'::geography,
    'Zara, Zara tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','sivas','zara']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:16:17.845Z'::timestamptz,
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
    (select id from public.provinces where slug = 'sirnak' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'sirnak' and d.slug = 'cizre' limit 1),
    'Cizre',
    'cizre',
    'historical'::public.place_category,
    'SRID=4326;POINT(42.1909199 37.3215265)'::geography,
    'Cizre, Cizre tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','şırnak','cizre']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:16:19.686Z'::timestamptz,
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
    (select id from public.provinces where slug = 'sirnak' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'sirnak' and d.slug = 'cizre' limit 1),
    'Nuh Turbesi',
    'nuh-turbesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(42.1881189 37.3240381)'::geography,
    'Nuh Turbesi, Cizre tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','şırnak','cizre']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:16:21.406Z'::timestamptz,
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
    (select id from public.provinces where slug = 'sirnak' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'sirnak' and d.slug = 'uludere' limit 1),
    'Uludere',
    'uludere',
    'historical'::public.place_category,
    'SRID=4326;POINT(42.8513576 37.4467396)'::geography,
    'Uludere, Uludere tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','şırnak','uludere']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:16:23.109Z'::timestamptz,
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
    (select id from public.provinces where slug = 'sirnak' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'sirnak' and d.slug = 'merkez' limit 1),
    'Cudi Dagi',
    'cudi-dagi',
    'historical'::public.place_category,
    'SRID=4326;POINT(42.4543142 37.377528)'::geography,
    'Cudi Dagi, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','şırnak','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:16:25.435Z'::timestamptz,
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
    (select id from public.provinces where slug = 'sirnak' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'sirnak' and d.slug = 'silopi' limit 1),
    'Silopi',
    'silopi',
    'historical'::public.place_category,
    'SRID=4326;POINT(42.5958273 37.3107363)'::geography,
    'Silopi, Silopi tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','şırnak','silopi']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:16:27.831Z'::timestamptz,
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
    (select id from public.provinces where slug = 'tekirdag' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'tekirdag' and d.slug = 'sarkoy' limit 1),
    'Sarkoy',
    'sarkoy',
    'beach'::public.place_category,
    'SRID=4326;POINT(27.0962571 40.6387044)'::geography,
    'Sarkoy, Sarkoy tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','tekirdağ','sarkoy']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:16:32.735Z'::timestamptz,
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
    (select id from public.provinces where slug = 'tekirdag' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'tekirdag' and d.slug = 'sarkoy' limit 1),
    'Gazikoy',
    'gazikoy',
    'beach'::public.place_category,
    'SRID=4326;POINT(27.3322013 40.7467106)'::geography,
    'Gazikoy, Sarkoy tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.',
    'day'::public.best_time,
    120,
    array['must-see','iconic','tekirdağ','sarkoy']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:16:34.569Z'::timestamptz,
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
    (select id from public.provinces where slug = 'tekirdag' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'tekirdag' and d.slug = 'malkara' limit 1),
    'Malkara',
    'malkara',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.0549404 40.8605501)'::geography,
    'Malkara, Malkara tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','tekirdağ','malkara']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:16:36.603Z'::timestamptz,
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
    (select id from public.provinces where slug = 'tekirdag' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'tekirdag' and d.slug = 'corlu' limit 1),
    'Corlu',
    'corlu',
    'historical'::public.place_category,
    'SRID=4326;POINT(27.7784255 41.1777226)'::geography,
    'Corlu, Corlu tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','tekirdağ','corlu']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:16:38.344Z'::timestamptz,
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
    (select id from public.provinces where slug = 'tokat' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'tokat' and d.slug = 'merkez' limit 1),
    'Tokat Kalesi',
    'tokat-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(36.5484865 40.317774)'::geography,
    'Tokat Kalesi, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','tokat','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:16:40.142Z'::timestamptz,
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
    (select id from public.provinces where slug = 'tokat' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'tokat' and d.slug = 'niksar' limit 1),
    'Niksar Kalesi',
    'niksar-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(36.9593553 40.5919818)'::geography,
    'Niksar Kalesi, Niksar tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','tokat','niksar']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:16:43.375Z'::timestamptz,
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
    (select id from public.provinces where slug = 'tokat' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'tokat' and d.slug = 'pazar' limit 1),
    'Ballica Magarasi',
    'ballica-magarasi',
    'nature'::public.place_category,
    'SRID=4326;POINT(36.3015033 40.2273137)'::geography,
    'Ballica Magarasi, Pazar bolgesinde one cikan doga ve gezi duraklarindan biridir.',
    'day'::public.best_time,
    90,
    array['must-see','iconic','tokat','pazar']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:16:45.506Z'::timestamptz,
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
    (select id from public.provinces where slug = 'tokat' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'tokat' and d.slug = 'zile' limit 1),
    'Zile Kalesi',
    'zile-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(35.8907216 40.3039225)'::geography,
    'Zile Kalesi, Zile tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','tokat','zile']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:16:47.338Z'::timestamptz,
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
    (select id from public.provinces where slug = 'tunceli' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'tunceli' and d.slug = 'merkez' limit 1),
    'Tunceli',
    'tunceli',
    'historical'::public.place_category,
    'SRID=4326;POINT(39.5482693 39.1060641)'::geography,
    'Tunceli, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','tunceli','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:16:52.521Z'::timestamptz,
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
    (select id from public.provinces where slug = 'tunceli' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'tunceli' and d.slug = 'pertek' limit 1),
    'Pertek Kalesi',
    'pertek-kalesi',
    'historical'::public.place_category,
    'SRID=4326;POINT(39.2717809 38.8437598)'::geography,
    'Pertek Kalesi, Pertek tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','tunceli','pertek']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:16:54.857Z'::timestamptz,
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
    (select id from public.provinces where slug = 'tunceli' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'tunceli' and d.slug = 'hozat' limit 1),
    'Hozat',
    'hozat',
    'historical'::public.place_category,
    'SRID=4326;POINT(39.2362815 39.1016828)'::geography,
    'Hozat, Hozat tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','tunceli','hozat']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:16:56.533Z'::timestamptz,
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
    (select id from public.provinces where slug = 'usak' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'usak' and d.slug = 'merkez' limit 1),
    'Usak',
    'usak',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.4074222 38.6639088)'::geography,
    'Usak, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','uşak','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:16:59.805Z'::timestamptz,
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
    (select id from public.provinces where slug = 'usak' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'usak' and d.slug = 'karahalli' limit 1),
    'Karahalli',
    'karahalli',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.5561447 38.3327192)'::geography,
    'Karahalli, Karahalli tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','uşak','karahalli']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:17:03.172Z'::timestamptz,
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
    (select id from public.provinces where slug = 'yalova' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'yalova' and d.slug = 'termal' limit 1),
    'Termal',
    'termal',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.1729757 40.6067667)'::geography,
    'Termal, Termal tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','yalova','termal']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:17:06.545Z'::timestamptz,
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
    (select id from public.provinces where slug = 'yalova' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'yalova' and d.slug = 'cinarcik' limit 1),
    'Cinarcik',
    'cinarcik',
    'historical'::public.place_category,
    'SRID=4326;POINT(29.1193054 40.6081144)'::geography,
    'Cinarcik, Cinarcik tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','yalova','cinarcik']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:17:10.178Z'::timestamptz,
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
    (select id from public.provinces where slug = 'yozgat' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'yozgat' and d.slug = 'merkez' limit 1),
    'Yozgat Camligi',
    'yozgat-camligi',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.8066674 39.8063829)'::geography,
    'Yozgat Camligi, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','yozgat','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:17:13.735Z'::timestamptz,
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
    (select id from public.provinces where slug = 'yozgat' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'yozgat' and d.slug = 'merkez' limit 1),
    'Yozgat',
    'yozgat',
    'historical'::public.place_category,
    'SRID=4326;POINT(34.8080972 39.8221974)'::geography,
    'Yozgat, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','yozgat','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:17:15.800Z'::timestamptz,
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
    (select id from public.provinces where slug = 'yozgat' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'yozgat' and d.slug = 'sorgun' limit 1),
    'Sorgun',
    'sorgun',
    'historical'::public.place_category,
    'SRID=4326;POINT(35.158587 39.8266852)'::geography,
    'Sorgun, Sorgun tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','yozgat','sorgun']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:17:19.049Z'::timestamptz,
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
    (select id from public.provinces where slug = 'zonguldak' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'zonguldak' and d.slug = 'merkez' limit 1),
    'Zonguldak',
    'zonguldak',
    'historical'::public.place_category,
    'SRID=4326;POINT(31.794162 41.4469746)'::geography,
    'Zonguldak, Merkez tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','zonguldak','merkez']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:17:21.274Z'::timestamptz,
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
    (select id from public.provinces where slug = 'zonguldak' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'zonguldak' and d.slug = 'eregli' limit 1),
    'Eregli',
    'eregli',
    'historical'::public.place_category,
    'SRID=4326;POINT(31.4195572 41.260765)'::geography,
    'Eregli, Eregli tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','zonguldak','eregli']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:17:24.568Z'::timestamptz,
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
    (select id from public.provinces where slug = 'zonguldak' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'zonguldak' and d.slug = 'caycuma' limit 1),
    'Caycuma',
    'caycuma',
    'historical'::public.place_category,
    'SRID=4326;POINT(32.095344 41.4241877)'::geography,
    'Caycuma, Caycuma tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','zonguldak','caycuma']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:17:27.875Z'::timestamptz,
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
    (select id from public.provinces where slug = 'zonguldak' limit 1),
    (select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = 'zonguldak' and d.slug = 'devrek' limit 1),
    'Devrek',
    'devrek',
    'historical'::public.place_category,
    'SRID=4326;POINT(31.977749 41.211689)'::geography,
    'Devrek, Devrek tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.',
    'day'::public.best_time,
    75,
    array['must-see','iconic','zonguldak','devrek']::text[],
    96,
    'admin_verified'::public.coordinate_source_kind,
    '2026-09-11T12:17:34.909Z'::timestamptz,
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
