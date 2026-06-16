-- Fix: grant SELECT on place_community_state to anon and authenticated roles.
-- The table had RLS policy "using (true)" but no explicit GRANT, causing
-- PostgREST to reject inline relationship joins from the mobile client.

grant select on public.place_community_state to anon, authenticated;

-- Also ensure place_images is readable (used by _getCommunityCoverPhotos fallback).
grant select on public.place_images to anon, authenticated;
