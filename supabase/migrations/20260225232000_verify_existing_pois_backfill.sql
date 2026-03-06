-- Restore visibility for existing compliant POIs by marking them as provenance-verified.
-- This does NOT relax Google blocks: source constraint remains enforced.

update public.pois
set provenance_verified = true,
    provenance_checked_at = now(),
    provenance_checked_by = null
where source in ('osm', 'wikidata', 'user', 'licensed')
  and coalesce(trim(name), '') <> ''
  and lat between -90 and 90
  and lng between -180 and 180;
