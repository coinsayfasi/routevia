-- Phase 1: hard compliance for legacy Google-origin places
ALTER TABLE public.places
  ADD COLUMN IF NOT EXISTS source text NOT NULL DEFAULT 'google',
  ADD COLUMN IF NOT EXISTS google_origin boolean NOT NULL DEFAULT true;

-- Existing rows inherit DEFAULT values on add-column.
-- Avoid bulk UPDATE on public.places to prevent publish/media guard triggers.

ALTER TABLE public.places ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "read_compliant_places" ON public.places;
CREATE POLICY "read_compliant_places"
ON public.places
FOR SELECT
USING (
  google_origin = false
  AND source <> 'google'
);

CREATE OR REPLACE VIEW public.places_public AS
SELECT *
FROM public.places
WHERE google_origin = false
  AND source <> 'google';

GRANT SELECT ON public.places_public TO anon, authenticated;

-- Phase 2: clean product dataset (non-Google only)
CREATE TABLE IF NOT EXISTS public.pois (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  category text NOT NULL,
  lat double precision NOT NULL CHECK (lat BETWEEN -90 AND 90),
  lng double precision NOT NULL CHECK (lng BETWEEN -180 AND 180),
  city text,
  district text,
  tags jsonb NOT NULL DEFAULT '[]'::jsonb,
  source text NOT NULL CHECK (source IN ('osm', 'wikidata', 'user', 'licensed')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS pois_category_lat_lng_idx ON public.pois (category, lat, lng);
CREATE INDEX IF NOT EXISTS pois_lat_idx ON public.pois (lat);
CREATE INDEX IF NOT EXISTS pois_lng_idx ON public.pois (lng);

ALTER TABLE public.pois ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "read_compliant_pois" ON public.pois;
CREATE POLICY "read_compliant_pois"
ON public.pois
FOR SELECT
TO anon, authenticated
USING (source IN ('osm', 'wikidata', 'user', 'licensed'));

DROP POLICY IF EXISTS "write_compliant_pois_admin" ON public.pois;
CREATE POLICY "write_compliant_pois_admin"
ON public.pois
FOR ALL
TO authenticated
USING (public.is_admin(auth.uid()))
WITH CHECK (public.is_admin(auth.uid()));
