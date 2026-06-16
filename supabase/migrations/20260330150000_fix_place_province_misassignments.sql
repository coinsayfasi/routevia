-- Fix confirmed province/district misassignments verified via OSM Nominatim reverse geocoding.
--
-- Methodology: all places with geog coordinates were checked against province centroids,
-- then top suspects were individually reverse-geocoded via Nominatim.
-- Only places where OSM definitively returns a different province are updated here.
--
-- Results:
--   Derebağ Milli Parkı       : Niğde → Kayseri / Yahyalı
--   Derebağ Şelalesi Tabiat Parkı: Niğde → Kayseri / Yahyalı
--   Kapuzbaşı Şelalesi        : Adana → Kayseri / Yahyalı
--   Elegance Resort Hotel     : Kocaeli → Yalova / Altınova

-- ── Derebağ Milli Parkı ──────────────────────────────────────────────────────
UPDATE public.places_clean
SET
  province_id = '797bc866-abea-4176-bb51-2f2ee2778174', -- Kayseri
  district_id = '70f9d74d-84dd-4fa9-8920-c5561ad8c5e3'  -- Yahyalı
WHERE id = 'b0c3caa1-13b8-4dbc-a447-97a8aa23f6cc';

-- ── Derebağ Şelalesi Tabiat Parkı ────────────────────────────────────────────
UPDATE public.places_clean
SET
  province_id = '797bc866-abea-4176-bb51-2f2ee2778174', -- Kayseri
  district_id = '70f9d74d-84dd-4fa9-8920-c5561ad8c5e3'  -- Yahyalı
WHERE id = '7fd74544-b806-428d-b681-f0caf89b0303';

-- ── Kapuzbaşı Şelalesi ───────────────────────────────────────────────────────
UPDATE public.places_clean
SET
  province_id = '797bc866-abea-4176-bb51-2f2ee2778174', -- Kayseri
  district_id = '70f9d74d-84dd-4fa9-8920-c5561ad8c5e3'  -- Yahyalı
WHERE id = (
  SELECT id FROM public.places_clean
  WHERE name ILIKE '%kapuzbaşı%'
  LIMIT 1
);

-- ── Elegance Resort Hotel (Altınova, Yalova) ─────────────────────────────────
UPDATE public.places_clean
SET
  province_id = 'f9856b76-1160-4a56-aa1c-7bc5e9919ebd', -- Yalova
  district_id = '5a2820b0-882f-4483-95d8-3a60abb1c213'  -- Altınova
WHERE id = (
  SELECT id FROM public.places_clean
  WHERE name ILIKE '%elegance resort%'
  LIMIT 1
);
