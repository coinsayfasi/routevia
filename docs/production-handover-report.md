# Routevia Production Handover Report

Generated: 2026-02-23 (UTC)
Project: `xfswonqskciufcnsehfc` (`routevia-prod`)

## 1) Executive Status
- Core platform is operational: PostGIS schema, RLS, edge functions, SQL-only boundaries seed, Flutter app.
- Ingestion is active and writing multi-source POIs (`curated`, `legacy_provider`, `osm`).
- Mobile critical UX fixes shipped: cluster behavior, marker tap -> detail, legacy rating fallback visibility.
- Queue is **not yet fully drained**; safe resume scripts are included.

## 2) Verification Snapshot (Before / After)

### Before (snapshot)
- Timestamp: `2026-02-22T20:54:25Z`
- Jobs: `queued=627`, `running=6`, `done=340`, `failed=0`
- Places by source: `curated=1144`, `legacy_provider=632`, `osm=187`
- Places total: `1963`

### After (latest stable snapshot in this handover)
- Timestamp: `2026-02-22T21:30+Z` window
- Jobs: `queued=614`, `running=0`, `done=359`, `failed=0`
- Places by source: `curated=1144`, `legacy_provider=989`, `osm=494`
- Places total: `2627`

Delta (hand-over window):
- `done +19`
- `places_total +664`
- `legacy_provider +357`
- `osm +307`

## 3) Coverage Heat (Current Signal)
- Lowest-density districts still include (from `get_ingest_progress.bottom_20_districts`):
  - 19 Mayıs (Samsun)
  - Acıgöl (Nevşehir)
  - Adaklı (Bingöl)
  - Adalar (İstanbul)
  - Adapazarı (Sakarya)
- Interpretation:
  - Pipeline healthy and filling dense metro areas first.
  - District-level long tail remains and must be completed by queue drain run.

## 4) Critical Fixes Applied

### Backend
- Legacy provider ingest migrated to compatible request flow.
- OSM ingest segmented to reduce heavy-query failures.
- `run_ingest_batch` hardened with per-job timeout (`ingest_district_timeout`) so batch endpoint returns deterministically.
- `get_ingest_progress` switched to exact count queries for accurate `places_by_source` reporting.

### Mobile UX
- `apps/mobile/lib/src/features/map/map_screen.dart`
  - Zoom-adaptive clustering.
  - Cluster tap zoom-in.
  - Single marker tap opens place detail.
  - Rating badge now uses community stats first, legacy fallback second.
- `apps/mobile/lib/src/data/routevia_repository.dart`
  - Place detail query now includes source/rating metadata fields.
- `apps/mobile/lib/src/features/place/place_detail_screen.dart`
  - Detail loads even if stats request fails.
  - Visible rating fallback from legacy source when community reviews absent.

## 5) Release Checklist
- [x] `supabase db reset` (local) loads `81 provinces`, `973 districts`.
- [x] Edge functions deployed for core + ingest.
- [x] `flutter analyze` clean.
- [x] iPhone release install + launch successful.
- [x] Nearby returns dense results (`nearby_places` top 50 in tested region).
- [ ] Queue drain to zero (`queued=0`, `running=0`) pending long-run operation.

## 6) Go-Live Cutover Plan
1. Rotate all exposed keys (service role + external provider keys) before production freeze.
2. Start controlled drain run from ops terminal and keep it alive until zero.
3. Monitor every 2-5 minutes via `npm run ingest:report` or direct `get_ingest_progress`.
4. When queue reaches zero:
   - Export final before/after metrics.
   - Spot check 10 random provinces + 20 random districts in app map.
   - Lock ingestion cadence to maintenance mode (periodic refresh only).
5. Publish mobile build after smoke tests (`Nearby`, `Filters`, `Place Detail`, `Share`).

## 7) Operational Commands

From repo root:

```bash
# progress
node tools/ingest_worker/worker.mjs --report

# single safe batch step (recommended while monitoring)
set -a && source .env && set +a
curl -sS -X POST "$SUPABASE_URL/functions/v1/run_ingest_batch" \
  -H "Content-Type: application/json" \
  -H "apikey: $SUPABASE_PUBLISHABLE_KEY" \
  -H "x-worker-secret: $SUPABASE_SERVICE_ROLE_KEY" \
  --data '{"limit":1}' | jq

# recover stuck running jobs
curl -sS -X POST "$SUPABASE_URL/functions/v1/reset_stuck_running_jobs" \
  -H "Content-Type: application/json" \
  -H "apikey: $SUPABASE_PUBLISHABLE_KEY" \
  -H "x-worker-secret: $SUPABASE_SERVICE_ROLE_KEY" \
  --data '{"stale_minutes":1}' | jq
```

## 8) Known Risks / Notes
- Long-running ingest API calls can intermittently timeout network-side.
- Mitigation in place: per-job timeout in `run_ingest_batch` + stuck job reset endpoint.
- Recommended ops mode until queue zero: low batch size (`limit=1..3`) with frequent progress checks.
