-- Premium runtime density + category dictionary + score v2 + nearby v2 RPC

-- 1) Expand source_kind enum for long-term legal sources
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_type WHERE typnamespace = 'public'::regnamespace AND typname = 'source_kind'
  ) THEN
    IF NOT EXISTS (
      SELECT 1 FROM pg_enum e JOIN pg_type t ON t.oid = e.enumtypid
      WHERE t.typname = 'source_kind' AND e.enumlabel = 'wikidata'
    ) THEN
      ALTER TYPE public.source_kind ADD VALUE 'wikidata';
    END IF;

    IF NOT EXISTS (
      SELECT 1 FROM pg_enum e JOIN pg_type t ON t.oid = e.enumtypid
      WHERE t.typname = 'source_kind' AND e.enumlabel = 'user'
    ) THEN
      ALTER TYPE public.source_kind ADD VALUE 'user';
    END IF;
  END IF;
END $$;

-- 2) Category dictionary (TR labels + icon mapping)
CREATE TABLE IF NOT EXISTS public.category_dictionary (
  category_key text PRIMARY KEY,
  group_key text NOT NULL,
  display_name_tr text NOT NULL,
  icon_key text NOT NULL,
  default_priority numeric NOT NULL DEFAULT 1,
  is_major boolean NOT NULL DEFAULT true
);

INSERT INTO public.category_dictionary (category_key, group_key, display_name_tr, icon_key, default_priority, is_major)
VALUES
  ('museum', 'culture', 'Müze', 'museum', 1.15, true),
  ('mosque', 'culture', 'Cami', 'mosque', 1.10, true),
  ('church', 'culture', 'Kilise', 'church', 1.05, true),
  ('synagogue', 'culture', 'Sinagog', 'synagogue', 1.05, true),
  ('monument', 'culture', 'Anıt', 'monument', 1.00, true),
  ('historical_site', 'culture', 'Tarihi Yer', 'history', 1.20, true),
  ('archeological_site', 'culture', 'Arkeolojik Alan', 'ruins', 1.25, true),
  ('castle_fortress', 'culture', 'Kale/Hisar', 'castle', 1.18, true),

  ('beach', 'nature', 'Plaj', 'beach_access', 1.20, true),
  ('bay_cove', 'nature', 'Koy', 'water', 1.22, true),
  ('waterfall', 'nature', 'Şelale', 'waterfall_chart', 1.30, true),
  ('canyon', 'nature', 'Kanyon', 'terrain', 1.30, true),
  ('lake', 'nature', 'Göl', 'lake', 1.10, true),
  ('forest_park', 'nature', 'Orman/Park', 'forest', 1.05, true),
  ('national_park', 'nature', 'Milli Park', 'park', 1.25, true),
  ('hiking_trail', 'nature', 'Yürüyüş Rotası', 'hiking', 1.15, true),

  ('viewpoint', 'views', 'Seyir Noktası', 'visibility', 1.20, true),
  ('sunrise_spot', 'views', 'Gün Doğumu Noktası', 'wb_sunny', 1.15, true),
  ('sunset_spot', 'views', 'Gün Batımı Noktası', 'wb_twilight', 1.25, true),

  ('food_restaurant', 'food', 'Restoran', 'restaurant', 1.10, true),
  ('cafe', 'food', 'Kafe', 'local_cafe', 1.05, true),
  ('dessert', 'food', 'Tatlıcı', 'icecream', 1.00, true),
  ('street_food', 'food', 'Sokak Lezzeti', 'fastfood', 0.95, true),

  ('tour_boat', 'activity', 'Tekne Turu', 'directions_boat', 1.18, true),
  ('tour_city', 'activity', 'Şehir Turu', 'tour', 1.05, true),
  ('activity_family', 'activity', 'Aile Aktivitesi', 'family_restroom', 1.00, true),
  ('activity_adventure', 'activity', 'Macera Aktivitesi', 'downhill_skiing', 1.15, true),
  ('ski_resort', 'activity', 'Kayak Merkezi', 'downhill_skiing', 1.25, true),
  ('thermal_spa', 'activity', 'Termal/Spa', 'spa', 1.10, true),
  ('marina', 'activity', 'Marina', 'sailing', 1.00, true),
  ('nightlife', 'activity', 'Gece Hayatı', 'nightlife', 0.95, true),

  ('lodging_hotel', 'lodging', 'Otel', 'hotel', 1.00, true),
  ('lodging_boutique', 'lodging', 'Butik Otel', 'villa', 1.05, true),
  ('lodging_camp', 'lodging', 'Kamp', 'camping', 1.00, true),
  ('lodging_bungalow', 'lodging', 'Bungalov', 'cabin', 1.05, true)
ON CONFLICT (category_key) DO UPDATE
SET group_key = EXCLUDED.group_key,
    display_name_tr = EXCLUDED.display_name_tr,
    icon_key = EXCLUDED.icon_key,
    default_priority = EXCLUDED.default_priority,
    is_major = EXCLUDED.is_major;

ALTER TABLE public.category_dictionary ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS category_dictionary_public_read ON public.category_dictionary;
CREATE POLICY category_dictionary_public_read
ON public.category_dictionary
FOR SELECT
TO anon, authenticated
USING (true);

-- 3) Extend places for premium runtime model (non-breaking)
ALTER TABLE IF EXISTS public.places
  ADD COLUMN IF NOT EXISTS normalized_name text,
  ADD COLUMN IF NOT EXISTS category_key text,
  ADD COLUMN IF NOT EXISTS rating numeric,
  ADD COLUMN IF NOT EXISTS rating_count int,
  ADD COLUMN IF NOT EXISTS province text,
  ADD COLUMN IF NOT EXISTS district text,
  ADD COLUMN IF NOT EXISTS lat double precision,
  ADD COLUMN IF NOT EXISTS lng double precision,
  ADD COLUMN IF NOT EXISTS short_desc text,
  ADD COLUMN IF NOT EXISTS hap_history text,
  ADD COLUMN IF NOT EXISTS hap_eat text,
  ADD COLUMN IF NOT EXISTS hap_tips text,
  ADD COLUMN IF NOT EXISTS open_hours_raw text,
  ADD COLUMN IF NOT EXISTS wikidata_id text,
  ADD COLUMN IF NOT EXISTS wikipedia_title text,
  ADD COLUMN IF NOT EXISTS is_family_friendly boolean NOT NULL DEFAULT false;

ALTER TABLE IF EXISTS public.place_media
  ADD COLUMN IF NOT EXISTS source text,
  ADD COLUMN IF NOT EXISTS license text,
  ADD COLUMN IF NOT EXISTS attribution text,
  ADD COLUMN IF NOT EXISTS url_original text,
  ADD COLUMN IF NOT EXISTS is_primary boolean NOT NULL DEFAULT false;

ALTER TABLE IF EXISTS public.places
  DROP CONSTRAINT IF EXISTS places_rating_check;
ALTER TABLE IF EXISTS public.places
  ADD CONSTRAINT places_rating_check CHECK (rating IS NULL OR (rating >= 0 AND rating <= 5));

ALTER TABLE IF EXISTS public.places
  DROP CONSTRAINT IF EXISTS places_rating_count_check;
ALTER TABLE IF EXISTS public.places
  ADD CONSTRAINT places_rating_count_check CHECK (rating_count IS NULL OR rating_count >= 0);

ALTER TABLE IF EXISTS public.places
  DROP CONSTRAINT IF EXISTS places_category_key_fkey;
ALTER TABLE IF EXISTS public.places
  ADD CONSTRAINT places_category_key_fkey
  FOREIGN KEY (category_key) REFERENCES public.category_dictionary(category_key)
  ON UPDATE CASCADE ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_places_district_published_score
  ON public.places(district_id, is_published, score DESC);
CREATE INDEX IF NOT EXISTS idx_places_district_category_published_score
  ON public.places(district_id, category_key, is_published, score DESC);
CREATE INDEX IF NOT EXISTS idx_places_province_district_published
  ON public.places(province, district, is_published);
CREATE INDEX IF NOT EXISTS idx_places_normalized_name
  ON public.places(normalized_name);
CREATE INDEX IF NOT EXISTS idx_place_media_place_primary
  ON public.place_media(place_id, is_primary);

-- Keep denormalized convenience fields in sync
CREATE OR REPLACE FUNCTION public.sync_place_denorm_fields()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  v_province text;
  v_district text;
BEGIN
  NEW.normalized_name := lower(regexp_replace(coalesce(NEW.name, ''), '[^a-zA-Z0-9ığüşöçİĞÜŞÖÇ]+', ' ', 'g'));

  IF NEW.geog IS NOT NULL THEN
    NEW.lat := ST_Y(NEW.geog::geometry);
    NEW.lng := ST_X(NEW.geog::geometry);
  END IF;

  IF NEW.short_desc IS NULL THEN
    NEW.short_desc := NEW.short_summary;
  END IF;

  IF NEW.rating IS NULL THEN
    NEW.rating := NEW.google_rating;
  END IF;

  IF NEW.rating_count IS NULL THEN
    NEW.rating_count := NEW.google_review_count;
  END IF;

  IF NEW.category_key IS NULL THEN
    NEW.category_key := CASE NEW.category::text
      WHEN 'museum' THEN 'museum'
      WHEN 'historical' THEN 'historical_site'
      WHEN 'nature' THEN 'forest_park'
      WHEN 'beach' THEN 'beach'
      WHEN 'viewpoint' THEN 'viewpoint'
      WHEN 'market' THEN 'street_food'
      WHEN 'cafe' THEN 'cafe'
      WHEN 'food' THEN 'food_restaurant'
      WHEN 'activity' THEN 'activity_family'
      WHEN 'lodging' THEN 'lodging_hotel'
      WHEN 'tour' THEN 'tour_city'
      WHEN 'ski' THEN 'ski_resort'
      WHEN 'waterfall' THEN 'waterfall'
      WHEN 'canyon' THEN 'canyon'
      ELSE NULL
    END;
  END IF;

  IF NEW.province_id IS NOT NULL THEN
    SELECT p.name INTO v_province FROM public.provinces p WHERE p.id = NEW.province_id;
    NEW.province := v_province;
  END IF;

  IF NEW.district_id IS NOT NULL THEN
    SELECT d.name INTO v_district FROM public.districts d WHERE d.id = NEW.district_id;
    NEW.district := v_district;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_sync_place_denorm_fields ON public.places;
CREATE TRIGGER trg_sync_place_denorm_fields
BEFORE INSERT OR UPDATE OF name, geog, category, category_key, province_id, district_id, short_summary, rating, rating_count
ON public.places
FOR EACH ROW
EXECUTE FUNCTION public.sync_place_denorm_fields();

-- One-time backfill
UPDATE public.places p
SET
  normalized_name = lower(regexp_replace(coalesce(p.name, ''), '[^a-zA-Z0-9ığüşöçİĞÜŞÖÇ]+', ' ', 'g')),
  lat = COALESCE(p.lat, ST_Y(p.geog::geometry)),
  lng = COALESCE(p.lng, ST_X(p.geog::geometry)),
  province = COALESCE(p.province, pr.name),
  district = COALESCE(p.district, (SELECT d2.name FROM public.districts d2 WHERE d2.id = p.district_id)),
  short_desc = COALESCE(p.short_desc, p.short_summary),
  rating = COALESCE(p.rating, p.google_rating),
  rating_count = COALESCE(p.rating_count, p.google_review_count),
  category_key = COALESCE(
    p.category_key,
    CASE p.category::text
      WHEN 'museum' THEN 'museum'
      WHEN 'historical' THEN 'historical_site'
      WHEN 'nature' THEN 'forest_park'
      WHEN 'beach' THEN 'beach'
      WHEN 'viewpoint' THEN 'viewpoint'
      WHEN 'market' THEN 'street_food'
      WHEN 'cafe' THEN 'cafe'
      WHEN 'food' THEN 'food_restaurant'
      WHEN 'activity' THEN 'activity_family'
      WHEN 'lodging' THEN 'lodging_hotel'
      WHEN 'tour' THEN 'tour_city'
      WHEN 'ski' THEN 'ski_resort'
      WHEN 'waterfall' THEN 'waterfall'
      WHEN 'canyon' THEN 'canyon'
      ELSE NULL
    END
  )
FROM public.provinces pr
WHERE pr.id = p.province_id
  AND p.is_published = false;

-- 4) Feature flags
CREATE TABLE IF NOT EXISTS public.feature_flags (
  flag_name text PRIMARY KEY,
  value_bool boolean NOT NULL,
  expires_at timestamptz
);

ALTER TABLE public.feature_flags ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS feature_flags_read_all ON public.feature_flags;
CREATE POLICY feature_flags_read_all
ON public.feature_flags
FOR SELECT
TO anon, authenticated
USING (true);

DROP POLICY IF EXISTS feature_flags_admin_write ON public.feature_flags;
CREATE POLICY feature_flags_admin_write
ON public.feature_flags
FOR ALL
TO authenticated
USING (public.is_admin(auth.uid()))
WITH CHECK (public.is_admin(auth.uid()));

INSERT INTO public.feature_flags(flag_name, value_bool, expires_at)
VALUES
  ('google_bootstrap_ingest_enabled', false, now() + interval '30 days'),
  ('llm_suggestions_enabled', false, null)
ON CONFLICT (flag_name) DO NOTHING;

-- 5) Ingest queue compatibility + priority columns
ALTER TABLE IF EXISTS public.district_ingest_jobs
  ADD COLUMN IF NOT EXISTS priority_score int NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS mode text NOT NULL DEFAULT 'normal',
  ADD COLUMN IF NOT EXISTS radius_km int,
  ADD COLUMN IF NOT EXISTS locked_at timestamptz;

DROP VIEW IF EXISTS public.ingest_jobs;
CREATE VIEW public.ingest_jobs
WITH (security_invoker = on)
AS
SELECT
  id,
  district_id,
  status,
  priority_score,
  attempts,
  last_error,
  locked_at,
  created_at,
  updated_at
FROM public.district_ingest_jobs;

-- 6) Stronger public policies: only published content for anon/auth (admin still via dedicated policy)
DROP POLICY IF EXISTS public_read_places ON public.places;
CREATE POLICY public_read_places
ON public.places
FOR SELECT
TO anon, authenticated
USING (is_published = true OR public.is_admin(auth.uid()));

DROP POLICY IF EXISTS public_read_place_media ON public.place_media;
CREATE POLICY public_read_place_media
ON public.place_media
FOR SELECT
TO anon, authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.places p
    WHERE p.id = place_media.place_id
      AND (p.is_published = true OR public.is_admin(auth.uid()))
  )
);

-- 7) Score engine v2: quality + completeness + priority + penalties
CREATE OR REPLACE FUNCTION public.compute_place_score_v2(p_place_id uuid)
RETURNS numeric
LANGUAGE sql
STABLE
AS $$
  WITH b AS (
    SELECT
      p.id,
      p.name,
      p.source_kind,
      COALESCE(p.rating, p.google_rating, 0)::numeric AS rating,
      COALESCE(p.rating_count, p.google_review_count, 0)::numeric AS rating_count,
      COALESCE(p.popularity_score, 0)::numeric AS popularity,
      COALESCE(cd.default_priority, 1)::numeric AS cat_priority,
      EXISTS (SELECT 1 FROM public.place_media pm WHERE pm.place_id = p.id AND (pm.is_primary = true OR pm.sort_order = 0)) AS has_primary_photo,
      (COALESCE(NULLIF(trim(p.hap_history), ''), '') <> ''
        OR EXISTS (SELECT 1 FROM public.place_details pd WHERE pd.place_id = p.id AND COALESCE(array_length(pd.history_bullets, 1), 0) > 0)
      ) AS has_hap_history,
      (COALESCE(NULLIF(trim(p.hap_eat), ''), '') <> ''
        OR EXISTS (SELECT 1 FROM public.place_details pd WHERE pd.place_id = p.id AND COALESCE(array_length(pd.eat_drink_bullets, 1), 0) > 0)
      ) AS has_hap_eat,
      (COALESCE(NULLIF(trim(p.hap_tips), ''), '') <> ''
        OR EXISTS (SELECT 1 FROM public.place_details pd WHERE pd.place_id = p.id AND COALESCE(array_length(pd.tips_bullets, 1), 0) > 0)
      ) AS has_hap_tips,
      lower(trim(coalesce(p.name, ''))) AS lname,
      COALESCE(p.category_key, '') AS category_key,
      p.category::text AS category_raw
    FROM public.places p
    LEFT JOIN public.category_dictionary cd ON cd.category_key = p.category_key
    WHERE p.id = p_place_id
  )
  SELECT GREATEST(
    0,
    (b.rating * 2.4)
    + (LN(1 + b.rating_count) * 1.2)
    + (b.popularity * 0.06)
    + (CASE WHEN b.has_primary_photo THEN 2.2 ELSE 0 END)
    + (CASE WHEN b.has_hap_history THEN 0.8 ELSE 0 END)
    + (CASE WHEN b.has_hap_eat THEN 0.8 ELSE 0 END)
    + (CASE WHEN b.has_hap_tips THEN 0.8 ELSE 0 END)
    + (CASE WHEN b.source_kind::text = 'curated' THEN 1.6 ELSE 0 END)
    + (b.cat_priority * 1.3)
    - (
      CASE
        WHEN b.lname IN ('park', 'çocuk parkı', 'semt pazarı', 'pazar', 'market', 'parkı')
             AND b.category_key NOT IN ('historical_site', 'archeological_site', 'viewpoint', 'waterfall', 'canyon', 'beach', 'national_park')
             AND b.category_raw NOT IN ('historical', 'viewpoint', 'waterfall', 'canyon', 'beach')
        THEN 6.5
        ELSE 0
      END
    )
  )
  FROM b;
$$;

CREATE OR REPLACE FUNCTION public.refresh_place_score(p_place_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE public.places p
  SET score = public.compute_place_score_v2(p.id)
  WHERE p.id = p_place_id;
END;
$$;

-- Food quality gate: keep weak rows unpublished by default
CREATE OR REPLACE FUNCTION public.apply_food_publish_gate()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  v_is_food_like boolean;
  v_rating numeric;
  v_count int;
BEGIN
  v_is_food_like := (NEW.category::text IN ('food','cafe','lodging'))
    OR (COALESCE(NEW.category_key,'') IN ('food_restaurant','cafe','dessert','street_food','lodging_hotel','lodging_boutique','lodging_camp','lodging_bungalow'));

  IF NOT v_is_food_like THEN
    RETURN NEW;
  END IF;

  v_rating := COALESCE(NEW.rating, NEW.google_rating, 0);
  v_count := COALESCE(NEW.rating_count, NEW.google_review_count, 0);

  IF NEW.source_kind::text <> 'curated' THEN
    IF NOT ((v_rating >= 4.3 AND v_count >= 150) OR (v_rating >= 4.5 AND v_count >= 80)) THEN
      NEW.is_published := false;
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_food_publish_gate ON public.places;
CREATE TRIGGER trg_food_publish_gate
BEFORE INSERT OR UPDATE OF category, category_key, rating, rating_count, google_rating, google_review_count, source_kind
ON public.places
FOR EACH ROW
EXECUTE FUNCTION public.apply_food_publish_gate();

-- 8) District density stats (materialized view)
DROP MATERIALIZED VIEW IF EXISTS public.district_density_stats;
CREATE MATERIALIZED VIEW public.district_density_stats AS
WITH base AS (
  SELECT
    d.id AS district_id,
    COUNT(p.id) FILTER (WHERE p.is_published = true) AS total_places,
    COUNT(DISTINCT COALESCE(cd.group_key, 'other')) FILTER (
      WHERE p.is_published = true
        AND COALESCE(cd.is_major, false) = true
    ) AS major_category_count
  FROM public.districts d
  LEFT JOIN public.places p ON p.district_id = d.id
  LEFT JOIN public.category_dictionary cd ON cd.category_key = p.category_key
  GROUP BY d.id
)
SELECT
  b.district_id,
  b.total_places::int,
  b.major_category_count::int,
  CASE
    WHEN b.total_places >= 500 AND b.major_category_count >= 8 THEN 'A'
    WHEN b.total_places >= 250 AND b.major_category_count >= 8 THEN 'B'
    WHEN b.total_places >= 120 AND b.major_category_count >= 6 THEN 'C'
    ELSE 'ZAYIF'
  END AS grade,
  now() AS updated_at
FROM base b;

CREATE UNIQUE INDEX IF NOT EXISTS district_density_stats_district_uidx
  ON public.district_density_stats(district_id);

CREATE OR REPLACE FUNCTION public.refresh_district_density_stats()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY public.district_density_stats;
EXCEPTION WHEN OTHERS THEN
  REFRESH MATERIALIZED VIEW public.district_density_stats;
END;
$$;

GRANT SELECT ON public.district_density_stats TO anon, authenticated;

-- 9) Resolve nearest district helper for runtime scope
CREATE OR REPLACE FUNCTION public.resolve_nearest_district_rpc(
  p_lat double precision,
  p_lng double precision
)
RETURNS TABLE(
  district_id uuid,
  district_name text,
  province_id uuid,
  province_name text,
  distance_m double precision
)
LANGUAGE sql
STABLE
SECURITY INVOKER
AS $$
  WITH origin AS (
    SELECT ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography AS g
  )
  SELECT
    d.id,
    d.name,
    d.province_id,
    p.name,
    ST_Distance(d.center_geog, o.g) AS distance_m
  FROM public.districts d
  JOIN public.provinces p ON p.id = d.province_id
  CROSS JOIN origin o
  ORDER BY d.center_geog <-> o.g
  LIMIT 1;
$$;

GRANT EXECUTE ON FUNCTION public.resolve_nearest_district_rpc(double precision, double precision)
TO anon, authenticated;

-- 10) Nearby v2 RPC with district bias + advanced filters + DB-only runtime
CREATE OR REPLACE FUNCTION public.nearby_places_v2_rpc(
  p_lat double precision,
  p_lng double precision,
  p_radius_m integer,
  p_province_id uuid DEFAULT NULL,
  p_district_id uuid DEFAULT NULL,
  p_categories text[] DEFAULT NULL,
  p_tags text[] DEFAULT NULL,
  p_free_only boolean DEFAULT false,
  p_min_rating numeric DEFAULT NULL,
  p_min_reviews integer DEFAULT NULL,
  p_price_levels integer[] DEFAULT NULL,
  p_max_duration integer DEFAULT NULL,
  p_sort text DEFAULT 'senin_icin',
  p_limit integer DEFAULT 300
)
RETURNS TABLE (
  id uuid,
  province_id uuid,
  district_id uuid,
  province_name text,
  district_name text,
  name text,
  slug citext,
  category public.place_category,
  category_key text,
  short_summary text,
  best_time public.best_time,
  duration_min int,
  tags text[],
  popularity_score int,
  is_free boolean,
  source_kind public.source_kind,
  source_url text,
  rating numeric,
  review_count int,
  price_level int,
  score double precision,
  distance_m double precision,
  effective_distance_m double precision,
  lat double precision,
  lng double precision,
  image_path text,
  image_source_kind public.source_kind
)
LANGUAGE sql
STABLE
SECURITY INVOKER
AS $$
  WITH origin AS (
    SELECT ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography AS g
  ), ranked AS (
    SELECT
      p.id,
      p.province_id,
      p.district_id,
      pr.name AS province_name,
      d.name AS district_name,
      p.name,
      p.slug,
      p.category,
      p.category_key,
      p.short_summary,
      p.best_time,
      p.duration_min,
      p.tags,
      p.popularity_score,
      p.is_free,
      p.source_kind,
      p.source_url,
      COALESCE(p.rating, p.google_rating, ps.avg_rating, 0::numeric) AS effective_rating,
      COALESCE(p.rating_count, p.google_review_count, ps.review_count, 0)::int AS effective_review_count,
      p.price_level,
      COALESCE(p.score, 0)::double precision AS score,
      ST_Distance(p.geog, o.g) AS distance_m,
      (ST_Distance(p.geog, o.g)
        + CASE
            WHEN p_district_id IS NOT NULL AND p.district_id IS DISTINCT FROM p_district_id THEN 1500
            ELSE 0
          END
      ) AS effective_distance_m,
      ST_Y(p.geog::geometry) AS lat,
      ST_X(p.geog::geometry) AS lng,
      pm.storage_path AS image_path,
      COALESCE(pm.source_kind, 'curated'::public.source_kind) AS image_source_kind
    FROM public.places p
    CROSS JOIN origin o
    JOIN public.provinces pr ON pr.id = p.province_id
    LEFT JOIN public.districts d ON d.id = p.district_id
    LEFT JOIN public.place_stats ps ON ps.place_id = p.id
    LEFT JOIN LATERAL (
      SELECT m.storage_path, m.source_kind
      FROM public.place_media m
      WHERE m.place_id = p.id
      ORDER BY m.is_primary DESC, m.sort_order ASC, m.id ASC
      LIMIT 1
    ) pm ON TRUE
    WHERE p.is_published = true
      AND ST_DWithin(p.geog, o.g, p_radius_m)
      AND (p_province_id IS NULL OR p.province_id = p_province_id)
      AND (p_district_id IS NULL OR p.district_id = p_district_id OR p.province_id = p_province_id)
      AND (
        p_categories IS NULL
        OR COALESCE(array_length(p_categories, 1), 0) = 0
        OR COALESCE(p.category_key, p.category::text) = ANY(p_categories)
        OR p.category::text = ANY(p_categories)
      )
      AND (
        p_tags IS NULL
        OR COALESCE(array_length(p_tags, 1), 0) = 0
        OR p.tags && p_tags
      )
      AND (NOT p_free_only OR p.is_free = true)
      AND (p_min_rating IS NULL OR COALESCE(p.rating, p.google_rating, ps.avg_rating, 0::numeric) >= p_min_rating)
      AND (p_min_reviews IS NULL OR COALESCE(p.rating_count, p.google_review_count, ps.review_count, 0) >= p_min_reviews)
      AND (
        p_price_levels IS NULL
        OR COALESCE(array_length(p_price_levels, 1), 0) = 0
        OR p.price_level = ANY(p_price_levels)
      )
      AND (p_max_duration IS NULL OR p.duration_min <= p_max_duration)
  )
  SELECT
    r.id,
    r.province_id,
    r.district_id,
    r.province_name,
    r.district_name,
    r.name,
    r.slug,
    r.category,
    r.category_key,
    r.short_summary,
    r.best_time,
    r.duration_min,
    r.tags,
    r.popularity_score,
    r.is_free,
    r.source_kind,
    r.source_url,
    r.effective_rating,
    r.effective_review_count,
    r.price_level,
    r.score,
    r.distance_m,
    r.effective_distance_m,
    r.lat,
    r.lng,
    r.image_path,
    r.image_source_kind
  FROM ranked r
  ORDER BY
    CASE WHEN lower(COALESCE(p_sort, 'senin_icin')) IN ('distance', 'mesafe') THEN r.distance_m END ASC,
    CASE WHEN lower(COALESCE(p_sort, 'senin_icin')) IN ('rating', 'puan') THEN r.effective_rating END DESC,
    CASE WHEN lower(COALESCE(p_sort, 'senin_icin')) IN ('rating', 'puan') THEN r.effective_review_count END DESC,
    CASE WHEN lower(COALESCE(p_sort, 'senin_icin')) IN ('score', 'skor', 'senin_icin', 'smart') THEN r.score END DESC,
    CASE WHEN lower(COALESCE(p_sort, 'senin_icin')) IN ('score', 'skor', 'senin_icin', 'smart') THEN r.effective_distance_m END ASC,
    r.id ASC
  LIMIT GREATEST(1, LEAST(500, p_limit));
$$;

GRANT EXECUTE ON FUNCTION public.nearby_places_v2_rpc(
  double precision,
  double precision,
  integer,
  uuid,
  uuid,
  text[],
  text[],
  boolean,
  numeric,
  integer,
  integer[],
  integer,
  text,
  integer
) TO anon, authenticated;

-- 11) Keep score fresh on places/media updates
CREATE OR REPLACE FUNCTION public.trg_places_refresh_score()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  PERFORM public.refresh_place_score(COALESCE(NEW.id, OLD.id));
  RETURN COALESCE(NEW, OLD);
END;
$$;

DROP TRIGGER IF EXISTS trg_places_refresh_score ON public.places;
CREATE TRIGGER trg_places_refresh_score
AFTER INSERT OR UPDATE OF google_rating, google_review_count, rating, rating_count, popularity_score, tags, source_kind, category_key, hap_history, hap_eat, hap_tips
ON public.places
FOR EACH ROW
EXECUTE FUNCTION public.trg_places_refresh_score();

DROP TRIGGER IF EXISTS trg_place_media_refresh_score_iud ON public.place_media;
CREATE TRIGGER trg_place_media_refresh_score_iud
AFTER INSERT OR UPDATE OR DELETE
ON public.place_media
FOR EACH ROW
EXECUTE FUNCTION public.trg_places_refresh_score();

-- Backfill score with v2 formula
DO $$
BEGIN
  UPDATE public.places p
  SET score = public.compute_place_score_v2(p.id)
  WHERE p.is_published = false;
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'score backfill skipped: %', SQLERRM;
END $$;

-- 12) Published-only place_details for anon/auth
DROP POLICY IF EXISTS public_read_place_details ON public.place_details;
CREATE POLICY public_read_place_details
ON public.place_details
FOR SELECT
TO anon, authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.places p
    WHERE p.id = place_details.place_id
      AND (p.is_published = true OR public.is_admin(auth.uid()))
  )
);
