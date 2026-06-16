# Production Runbook

## 1) Prepare Env
Set these secrets in Supabase project:
- `SUPABASE_SERVICE_ROLE_KEY` (worker header secret)
- `OVERPASS_URL`

## 2) Deploy
```bash
cd ~/Desktop/02_Projeler/routevia
supabase db push --include-all --yes
supabase functions deploy nearby_places sunset_now generate_trip_plan
supabase functions deploy share_trip get_shared_trip submit_review get_place_stats
supabase functions deploy ingest_district enqueue_all_district_jobs run_ingest_batch
supabase functions deploy get_ingest_progress requeue_failed_jobs reset_stuck_running_jobs
supabase functions deploy seed_turkey_admin
supabase functions deploy ingest_google_district google_place_enrich cache_google_thumbnails photo_proxy
```

## 3) Verify Seed
Call:
- `seed_turkey_admin`
Expect:
- provinces = 81
- districts = 973

## 4) Ingestion Ops
Start:
```bash
cd tools/ingest_worker
npm i
npm run ingest:turkey
```
Modes:
- one batch: `npm run ingest:once`
- resume without seed/enqueue: `npm run ingest:resume`
- progress only: `npm run ingest:report`

## 5) Recovery
If any jobs remain `running` too long:
- call `reset_stuck_running_jobs` with `stale_minutes`.
If failed jobs accumulate:
- call `requeue_failed_jobs` with `max_attempts`.

## 6) Policy Mode
System policy is `clean_only`:
- Runtime map/plan/search flows use only clean dataset.
- Legacy proprietary pipeline functions are deployed as `disabled_by_policy` (HTTP 410).
- Active worker tooling has no Google Places dependency.

## 7) Monitoring Snapshot
Use `get_ingest_progress` and track:
- jobs queued/running/done/failed
- places by source_kind/category
- bottom 20 districts by place_count
- recent failed jobs

## 8) Nightly District Self-Heal (GitHub Actions)
Workflow:
- `.github/workflows/nightly-poi-district-self-heal.yml`

Repository secrets required:
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`

What it does nightly:
- Runs `public.apply_poi_location_overrides()` RPC (manual override map in DB).
- Runs `tools/fix_poi_districts_nominatim.mjs` for geocode-based tail fixes.
- Produces `docs/reports/nightly_poi_district_quality.json` artifact.
- Fails pipeline if `issue_rate > 0.002`.

Manual trigger:
- GitHub Actions > `Nightly POI District Self-Heal` > `Run workflow`.

## 9) Nightly Backend Smoke (GitHub Actions)
Workflow:
- `.github/workflows/nightly-backend-smoke.yml`

Repository secrets required:
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`

What it validates:
- `provinces` count threshold
- `apply_poi_location_overrides()` RPC health
- `get_live_status` edge function health
- District quality thresholds (`missing/invalid/issue_rate`)

Artifact:
- `nightly_backend_smoke_report.json`

Manual trigger:
- GitHub Actions > `Nightly Backend Smoke` > `Run workflow`.
