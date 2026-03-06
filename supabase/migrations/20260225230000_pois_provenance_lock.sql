-- Provenance hard lock: only verified POIs can be read by product clients

ALTER TABLE public.pois
  ADD COLUMN IF NOT EXISTS provenance_verified boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS provenance_checked_at timestamptz,
  ADD COLUMN IF NOT EXISTS provenance_checked_by uuid REFERENCES auth.users(id) ON DELETE SET NULL;

-- Recreate read policy with strict provenance gate
DROP POLICY IF EXISTS "read_compliant_pois" ON public.pois;
CREATE POLICY "read_compliant_pois"
ON public.pois
FOR SELECT
TO anon, authenticated
USING (
  source IN ('osm', 'wikidata', 'user', 'licensed')
  AND provenance_verified = true
);

-- Safe public view for future clients/services
CREATE OR REPLACE VIEW public.pois_public AS
SELECT *
FROM public.pois
WHERE source IN ('osm', 'wikidata', 'user', 'licensed')
  AND provenance_verified = true;

GRANT SELECT ON public.pois_public TO anon, authenticated;
