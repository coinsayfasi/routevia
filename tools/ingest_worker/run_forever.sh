#!/usr/bin/env bash
set -u

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT_DIR"

LOG_DIR="$ROOT_DIR/tools/ingest_worker/logs"
mkdir -p "$LOG_DIR"
RUN_LOG="$LOG_DIR/supervisor-$(date +%Y%m%d-%H%M%S).log"

if [ -f "$ROOT_DIR/.env" ]; then
  set -a
  # shellcheck disable=SC1091
  source "$ROOT_DIR/.env"
  set +a
fi

if [ -z "${SUPABASE_URL:-}" ] || [ -z "${SUPABASE_SERVICE_ROLE_KEY:-}" ]; then
  echo "Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY" | tee -a "$RUN_LOG"
  exit 1
fi

echo "[start] supervisor $(date -u +%Y-%m-%dT%H:%M:%SZ)" | tee -a "$RUN_LOG"

while true; do
  echo "[loop] launch worker $(date -u +%Y-%m-%dT%H:%M:%SZ)" | tee -a "$RUN_LOG"
  # Hard watchdog timeout (seconds) to avoid rare hanging network calls.
  python3 - "$ROOT_DIR/tools/ingest_worker/worker.mjs" >> "$RUN_LOG" 2>&1 <<'PY'
import subprocess
import sys

worker = sys.argv[1]
cmd = [
    "node",
    worker,
    "--resume",
    "--until-done",
    "--batch=1",
    "--sleep=1200",
    "--http-timeout-ms=90000",
    "--max-errors=30",
    "--minutes=20",
]
try:
    proc = subprocess.run(cmd, timeout=90, check=False)
    sys.exit(proc.returncode)
except subprocess.TimeoutExpired:
    print("[watchdog] worker timed out after 90s", flush=True)
    sys.exit(124)
PY
  code=$?
  echo "[loop] worker exit_code=$code $(date -u +%Y-%m-%dT%H:%M:%SZ)" | tee -a "$RUN_LOG"

  progress_json=$(curl -sS -X POST "$SUPABASE_URL/functions/v1/get_ingest_progress" \
    -H "Content-Type: application/json" \
    -H "apikey: ${SUPABASE_PUBLISHABLE_KEY:-${SUPABASE_ANON_KEY:-}}" \
    -H "x-worker-secret: $SUPABASE_SERVICE_ROLE_KEY" \
    --data '{}')

  queued=$(echo "$progress_json" | jq -r '.jobs.queued // 0')
  running=$(echo "$progress_json" | jq -r '.jobs.running // 0')
  done=$(echo "$progress_json" | jq -r '.jobs.done // 0')
  places=$(echo "$progress_json" | jq -r '((.places_by_source // {}) | to_entries | map(.value) | add) // 0')

  echo "[loop] queued=$queued running=$running done=$done places=$places" | tee -a "$RUN_LOG"

  if [ "$running" -gt 0 ]; then
    curl -sS -X POST "$SUPABASE_URL/functions/v1/reset_stuck_running_jobs" \
      -H "Content-Type: application/json" \
      -H "apikey: ${SUPABASE_PUBLISHABLE_KEY:-${SUPABASE_ANON_KEY:-}}" \
      -H "x-worker-secret: $SUPABASE_SERVICE_ROLE_KEY" \
      --data '{"stale_minutes":1}' >> "$RUN_LOG" 2>&1 || true
    echo "[loop] reset_stuck_running_jobs requested" | tee -a "$RUN_LOG"
  fi

  if [ "$queued" -eq 0 ] && [ "$running" -eq 0 ]; then
    echo "[done] queue drained $(date -u +%Y-%m-%dT%H:%M:%SZ)" | tee -a "$RUN_LOG"
    break
  fi

  sleep 5
done

echo "[stop] supervisor finished" | tee -a "$RUN_LOG"
