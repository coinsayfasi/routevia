# Release Checklist

## Security
- Rotate previously exposed keys (Supabase secret/service role, external provider keys).
- Confirm `.env` is not committed.
- Confirm mobile app uses only `SUPABASE_URL` and `SUPABASE_ANON_KEY`.
- Confirm known exception note exists for `public.spatial_ref_sys` (PostGIS-owned) and compensating checks are passed (`docs/COMPLIANCE_NOTES.md` section 7).

## Database
- Run `supabase db reset` locally.
- Verify boundaries loaded from SQL seed:
  - provinces = 81
  - districts = 973
- Run `supabase db push --include-all --yes` to remote.
- Run `bash scripts/verify_google_compliance_db.sh` against remote.
- Confirm `public.google_compliance_audit()` returns `0` for:
  - `places_google_published`
  - `places_non_google_with_google_place_id`
  - `places_non_google_with_google_rating`
  - `places_non_google_with_google_url`
  - `place_media_non_google_google_refs`

## Edge Functions
- Deploy all core/admin functions.
- Verify admin functions are callable with `x-worker-secret`.
- Smoke test endpoints:
  - `nearby_places`
  - `sunset_now`
  - `generate_trip_plan`
  - `get_ingest_progress`

## Ingestion
- Start worker in dry mode: `npm run ingest:dry`.
- Start worker in live mode for controlled window:
  - `node worker.mjs --minutes=30`
- Track progress:
  - done increasing
  - failed stable/low
  - place count increasing

## Mobile
- `flutter pub get`
- `flutter analyze`
- Manual smoke tests:
  - GPS-first map load
  - Filter chips
  - Sunset banner
  - Place detail attribution
  - Trip share token read-only

## Go/No-Go
- Go only if:
  - queue progresses without growing failed backlog
  - app launch path is stable
  - attribution visible for source datasets
