-- ============================================================
-- Fix Elazığ & Erzincan: dedup, wrong-province cleanup, add
-- missing key tourist places
-- ============================================================

-- ─── 1. DEDUPLICATE places_clean ────────────────────────────
-- Keep the earliest-created record per (province_id, normalised name)
DELETE FROM places_clean
WHERE id NOT IN (
  SELECT DISTINCT ON (province_id, lower(trim(name))) id
  FROM places_clean
  ORDER BY province_id, lower(trim(name)), created_at ASC
)
AND id NOT IN (
  SELECT DISTINCT place_id FROM trip_stops_clean WHERE place_id IS NOT NULL
);

-- ─── 2. REMOVE WRONG-PROVINCE ENTRIES ───────────────────────
-- "Bingöl Hesarek Kayak Merkezi" is in Bingöl, not Elazığ
DELETE FROM places_clean
WHERE province_id = '9ac33b7d-835c-4a02-8911-0239976cc541'  -- elazig
  AND lower(trim(name)) LIKE '%hesarek%';

-- "Golova sivas" is in Sivas, not Erzincan
DELETE FROM places_clean
WHERE province_id = '7b8fb42c-0710-46fd-9dd8-530dc98cf0ee'  -- erzincan
  AND lower(trim(name)) LIKE '%golova%';

-- "ÇORBACI AHMET" in Erzincan has coordinate lon≈40.27 which is
-- far outside Erzincan (should be ~38-40); remove
DELETE FROM places_clean
WHERE province_id = '7b8fb42c-0710-46fd-9dd8-530dc98cf0ee'
  AND lower(trim(name)) LIKE '%çorbaci ahmet%';

-- ─── 3. ADD MISSING KEY TOURIST PLACES ──────────────────────

-- Hazar Gölü (Elazığ / Sivrice) — NOT in DB at all
INSERT INTO places_clean (
  id, province_id, district_id,
  name, slug, category,
  geog,
  short_summary, best_time, duration_min,
  tags, popularity_score,
  coordinate_source, coordinate_verified_at, coordinate_verified_by,
  created_at, updated_at
)
SELECT
  gen_random_uuid(),
  '9ac33b7d-835c-4a02-8911-0239976cc541',  -- elazig
  '769ca4c4-371d-43be-a1ab-44b1fbc8dbbb',  -- sivrice
  'Hazar Gölü',
  'hazar-golu',
  'nature',
  ST_SetSRID(ST_MakePoint(39.409882, 38.483265), 4326)::geography,
  'Türkiye''nin en derin göllerinden biri olan Hazar Gölü, 1250 m rakımda mavi bayraklı plajları ve su sporlarıyla öne çıkar. Gölün altında tarihi bir batık kent kalıntısı bulunmaktadır.',
  'day',
  180,
  ARRAY['doğa', 'göl', 'yüzme', 'kamp', 'batık kent'],
  85,
  'osm_verified',
  now(),
  'migration_20260327',
  now(), now()
WHERE NOT EXISTS (
  SELECT 1 FROM places_clean
  WHERE province_id = '9ac33b7d-835c-4a02-8911-0239976cc541'
    AND lower(trim(name)) = 'hazar gölü'
);

-- Buzluk Mağarası (Elazığ / Merkez-Harput) — NOT in DB at all
INSERT INTO places_clean (
  id, province_id, district_id,
  name, slug, category,
  geog,
  short_summary, best_time, duration_min,
  tags, popularity_score,
  coordinate_source, coordinate_verified_at, coordinate_verified_by,
  created_at, updated_at
)
SELECT
  gen_random_uuid(),
  '9ac33b7d-835c-4a02-8911-0239976cc541',  -- elazig
  '2d406d8a-a694-4dc1-a3a0-acc966858ad6',  -- merkez (harput bölgesi)
  'Buzluk Mağarası',
  'buzluk-magarasi',
  'nature',
  ST_SetSRID(ST_MakePoint(39.247602, 38.710482), 4326)::geography,
  'Yazın buz oluşturmasıyla benzersiz bir mağara. Harput Platosu üzerinde, ellips biçimli dolininde yaz aylarında doğal buz izlemek mümkündür.',
  'day',
  60,
  ARRAY['mağara', 'doğa', 'harput', 'buzluk'],
  72,
  'osm_verified',
  now(),
  'migration_20260327',
  now(), now()
WHERE NOT EXISTS (
  SELECT 1 FROM places_clean
  WHERE province_id = '9ac33b7d-835c-4a02-8911-0239976cc541'
    AND lower(trim(name)) = 'buzluk mağarası'
);

-- Altıntepe Ören Yeri (Erzincan / Üzümlü) — NOT in DB
INSERT INTO places_clean (
  id, province_id, district_id,
  name, slug, category,
  geog,
  short_summary, best_time, duration_min,
  tags, popularity_score,
  coordinate_source, coordinate_verified_at, coordinate_verified_by,
  created_at, updated_at
)
SELECT
  gen_random_uuid(),
  '7b8fb42c-0710-46fd-9dd8-530dc98cf0ee',  -- erzincan
  'c72484b4-c17b-494b-a227-887749b00cd7',  -- uzumlu
  'Altıntepe Ören Yeri',
  'altintepe-oren-yeri',
  'historical',
  ST_SetSRID(ST_MakePoint(39.651900, 39.802100), 4326)::geography,
  'MÖ 9-7. yüzyıllara tarihlenen Urartu medeniyetine ait önemli bir arkeolojik alan. Tapınak, saray ve anıtsal mezarlarıyla Batı''nın en önemli Urartu merkezlerinden biridir.',
  'day',
  90,
  ARRAY['urartu', 'arkeoloji', 'tarih', 'ören yeri'],
  78,
  'osm_verified',
  now(),
  'migration_20260327',
  now(), now()
WHERE NOT EXISTS (
  SELECT 1 FROM places_clean
  WHERE province_id = '7b8fb42c-0710-46fd-9dd8-530dc98cf0ee'
    AND lower(trim(name)) = 'altıntepe ören yeri'
);

-- Kemaliye Tarihi Kenti (Erzincan / Kemaliye) — ensure exists
INSERT INTO places_clean (
  id, province_id, district_id,
  name, slug, category,
  geog,
  short_summary, best_time, duration_min,
  tags, popularity_score,
  coordinate_source, coordinate_verified_at, coordinate_verified_by,
  created_at, updated_at
)
SELECT
  gen_random_uuid(),
  '7b8fb42c-0710-46fd-9dd8-530dc98cf0ee',  -- erzincan
  '42bfa949-cbea-447d-bbde-95b441d0b5d2',  -- kemaliye
  'Kemaliye Tarihi Kenti',
  'kemaliye-tarihi-kenti',
  'historical',
  ST_SetSRID(ST_MakePoint(38.494800, 39.261800), 4326)::geography,
  'UNESCO Dünya Mirası Geçici Listesi''ndeki Kemaliye (eski adıyla Eğin), geleneksel Osmanlı taş mimarisi, 38 tünelli Taş Yolu ve Karanlık Kanyon''uyla eşsiz bir tarihi kasabadır.',
  'day',
  360,
  ARRAY['tarihi kent', 'mimari', 'doğa', 'kemaliye', 'eğin', 'cittaslow'],
  90,
  'osm_verified',
  now(),
  'migration_20260327',
  now(), now()
WHERE NOT EXISTS (
  SELECT 1 FROM places_clean
  WHERE province_id = '7b8fb42c-0710-46fd-9dd8-530dc98cf0ee'
    AND lower(trim(name)) LIKE '%kemaliye tarihi%'
);
