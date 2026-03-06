#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT_DIR/docs/reports"
mkdir -p "$REPORT_DIR"

if [[ ! -f "$ROOT_DIR/.env" ]]; then
  echo "Missing $ROOT_DIR/.env" >&2
  exit 1
fi

set -a
source "$ROOT_DIR/.env"
set +a

if [[ -z "${SUPABASE_URL:-}" || -z "${SUPABASE_SERVICE_ROLE_KEY:-}" ]]; then
  echo "SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY missing in .env" >&2
  exit 1
fi

PASSES="${PASSES:-5}"
MAX_UPDATES="${MAX_UPDATES:-80}"
DELAY_MS="${DELAY_MS:-1100}"

STAMP="$(date +%Y%m%d_%H%M%S)"
BEFORE_JSON="$REPORT_DIR/poi_district_quality_before_${STAMP}.json"
AFTER_JSON="$REPORT_DIR/poi_district_quality_after_${STAMP}.json"
SUMMARY_JSON="$REPORT_DIR/poi_district_quality_summary_${STAMP}.json"
RUN_LOG="$REPORT_DIR/poi_district_cleanup_run_${STAMP}.log"

echo "[RUN] generating before report..."
node "$ROOT_DIR/tools/poi_district_quality_report.mjs" > "$BEFORE_JSON"

echo "[RUN] passes=$PASSES max_updates=$MAX_UPDATES delay_ms=$DELAY_MS" | tee "$RUN_LOG"
for i in $(seq 1 "$PASSES"); do
  echo "[RUN] pass $i/$PASSES started..." | tee -a "$RUN_LOG"
  node "$ROOT_DIR/tools/fix_poi_districts_nominatim.mjs" \
    --max-updates="$MAX_UPDATES" \
    --delay-ms="$DELAY_MS" | tee -a "$RUN_LOG"
  echo "[RUN] pass $i/$PASSES finished" | tee -a "$RUN_LOG"
done

echo "[RUN] generating after report..."
node "$ROOT_DIR/tools/poi_district_quality_report.mjs" > "$AFTER_JSON"

BEFORE_PATH="$BEFORE_JSON" \
AFTER_PATH="$AFTER_JSON" \
RUN_LOG_PATH="$RUN_LOG" \
SUMMARY_PATH="$SUMMARY_JSON" \
node <<'NODE'
const fs = require("node:fs");

const beforePath = process.env.BEFORE_PATH;
const afterPath = process.env.AFTER_PATH;
const runLogPath = process.env.RUN_LOG_PATH;
const summaryPath = process.env.SUMMARY_PATH;

const before = JSON.parse(fs.readFileSync(beforePath, "utf8"));
const after = JSON.parse(fs.readFileSync(afterPath, "utf8"));

const summary = {
  generated_at: new Date().toISOString(),
  before_report: beforePath,
  after_report: afterPath,
  run_log: runLogPath,
  before: {
    total_verified_pois: before.total_verified_pois,
    missing_district_count: before.missing_district_count,
    invalid_district_count: before.invalid_district_count,
    issue_rate: before.issue_rate,
  },
  after: {
    total_verified_pois: after.total_verified_pois,
    missing_district_count: after.missing_district_count,
    invalid_district_count: after.invalid_district_count,
    issue_rate: after.issue_rate,
  },
  delta: {
    missing_district_reduced_by:
      Number(before.missing_district_count || 0) -
      Number(after.missing_district_count || 0),
    invalid_district_reduced_by:
      Number(before.invalid_district_count || 0) -
      Number(after.invalid_district_count || 0),
    issue_rate_change:
      Number(after.issue_rate || 0) - Number(before.issue_rate || 0),
  },
};

fs.writeFileSync(summaryPath, JSON.stringify(summary, null, 2) + "\n");
NODE

echo "[DONE] before:  $BEFORE_JSON"
echo "[DONE] after:   $AFTER_JSON"
echo "[DONE] summary: $SUMMARY_JSON"
echo "[DONE] log:     $RUN_LOG"
