#!/usr/bin/env bash
set -u

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT_DIR"

if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

if [ -z "${SUPABASE_URL:-}" ] || [ -z "${SUPABASE_SERVICE_ROLE_KEY:-}" ]; then
  echo "Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY"
  exit 1
fi

APIKEY="${SUPABASE_PUBLISHABLE_KEY:-${SUPABASE_ANON_KEY:-}}"
if [ -z "$APIKEY" ]; then
  echo "Missing SUPABASE_PUBLISHABLE_KEY or SUPABASE_ANON_KEY"
  exit 1
fi

BATCH="${1:-1}"
SLEEP_MS="${INGEST_SLEEP_MS:-1200}"
ITER=0

echo "[start] curl_drain batch=$BATCH sleep_ms=$SLEEP_MS"

while true; do
  ITER=$((ITER+1))

  curl -sS --max-time 85 -X POST "$SUPABASE_URL/functions/v1/run_ingest_batch" \
    -H "Content-Type: application/json" \
    -H "apikey: $APIKEY" \
    -H "x-worker-secret: $SUPABASE_SERVICE_ROLE_KEY" \
    --data "{\"limit\":$BATCH}" > /tmp/routevia_run_batch.json || true

  if [ "$((ITER % 5))" -eq 0 ]; then
    curl -sS --max-time 25 -X POST "$SUPABASE_URL/functions/v1/get_ingest_progress" \
      -H "Content-Type: application/json" \
      -H "apikey: $APIKEY" \
      -H "x-worker-secret: $SUPABASE_SERVICE_ROLE_KEY" \
      --data '{}' > /tmp/routevia_progress_live.json || true

    queued=$(jq -r '.jobs.queued // 0' /tmp/routevia_progress_live.json 2>/dev/null || echo 0)
    running=$(jq -r '.jobs.running // 0' /tmp/routevia_progress_live.json 2>/dev/null || echo 0)
    done=$(jq -r '.jobs.done // 0' /tmp/routevia_progress_live.json 2>/dev/null || echo 0)
    failed=$(jq -r '.jobs.failed // 0' /tmp/routevia_progress_live.json 2>/dev/null || echo 0)
    places=$(jq -r '((.places_by_source // {}) | to_entries | map(.value) | add) // 0' /tmp/routevia_progress_live.json 2>/dev/null || echo 0)
    echo "[progress] iter=$ITER queued=$queued running=$running done=$done failed=$failed places=$places"

    if [ "$running" -gt 0 ]; then
      curl -sS --max-time 20 -X POST "$SUPABASE_URL/functions/v1/reset_stuck_running_jobs" \
        -H "Content-Type: application/json" \
        -H "apikey: $APIKEY" \
        -H "x-worker-secret: $SUPABASE_SERVICE_ROLE_KEY" \
        --data '{"stale_minutes":1}' > /tmp/routevia_reset_running.json || true
    fi

    if [ "$failed" -gt 0 ]; then
      curl -sS --max-time 20 -X POST "$SUPABASE_URL/functions/v1/requeue_failed_jobs" \
        -H "Content-Type: application/json" \
        -H "apikey: $APIKEY" \
        -H "x-worker-secret: $SUPABASE_SERVICE_ROLE_KEY" \
        --data '{"max_attempts":8}' > /tmp/routevia_requeue_failed.json || true
    fi

    if [ "$queued" -eq 0 ] && [ "$running" -eq 0 ]; then
      echo "[done] queue drained"
      break
    fi
  fi

  python3 - "$SLEEP_MS" <<'PY'
import sys, time
ms = float(sys.argv[1])
time.sleep(ms / 1000.0)
PY
done
