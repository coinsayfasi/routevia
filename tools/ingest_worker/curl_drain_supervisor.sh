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

APIKEY="${SUPABASE_PUBLISHABLE_KEY:-${SUPABASE_ANON_KEY:-}}"
LOG_DIR="$ROOT_DIR/tools/ingest_worker/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/curl-drain-supervisor-$(date +%Y%m%d-%H%M%S).log"

echo "[start] $(date -u +%Y-%m-%dT%H:%M:%SZ)" | tee -a "$LOG_FILE"

while true; do
  echo "[loop] launch drain worker" | tee -a "$LOG_FILE"
  python3 - "$ROOT_DIR/tools/ingest_worker/curl_drain.sh" >> "$LOG_FILE" 2>&1 <<'PY'
import subprocess
import sys
script = sys.argv[1]
try:
    rc = subprocess.run(["bash", script, "1"], timeout=110, check=False).returncode
    sys.exit(rc)
except subprocess.TimeoutExpired:
    print("[watchdog] curl_drain timed out after 110s", flush=True)
    sys.exit(124)
PY
  code=$?
  echo "[loop] drain worker exit_code=$code" | tee -a "$LOG_FILE"

  progress=$(curl -sS --max-time 20 -X POST "$SUPABASE_URL/functions/v1/get_ingest_progress" \
    -H "Content-Type: application/json" \
    -H "apikey: $APIKEY" \
    -H "x-worker-secret: $SUPABASE_SERVICE_ROLE_KEY" \
    --data '{}')

  queued=$(echo "$progress" | jq -r '.jobs.queued // 0')
  running=$(echo "$progress" | jq -r '.jobs.running // 0')
  done=$(echo "$progress" | jq -r '.jobs.done // 0')
  places=$(echo "$progress" | jq -r '((.places_by_source // {}) | to_entries | map(.value) | add) // 0')

  echo "[loop] queued=$queued running=$running done=$done places=$places" | tee -a "$LOG_FILE"

  if [ "$queued" -eq 0 ] && [ "$running" -eq 0 ]; then
    echo "[done] queue drained" | tee -a "$LOG_FILE"
    break
  fi

  sleep 2
done
