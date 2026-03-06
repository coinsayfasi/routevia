#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${SUPABASE_URL:-}" || -z "${SUPABASE_ANON_KEY:-}" ]]; then
  echo "SUPABASE_URL ve SUPABASE_ANON_KEY gerekli" >&2
  exit 1
fi

tmp_nearby=$(mktemp)
tmp_plan=$(mktemp)
tmp_detail=$(mktemp)

curl -sS -X POST "$SUPABASE_URL/functions/v1/nearby_places" \
  -H "apikey: $SUPABASE_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"lat":41.0082,"lng":28.9784,"radius_m":10000}' > "$tmp_nearby"

curl -sS -X POST "$SUPABASE_URL/functions/v1/generate_trip_plan_v2" \
  -H "apikey: $SUPABASE_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"province_slug":"istanbul","days":1,"pace":"medium","transport_mode":"car"}' > "$tmp_plan"

place_id=$(jq -r '.items[0].id // empty' "$tmp_nearby")
if [[ -n "$place_id" ]]; then
  curl -sS -X POST "$SUPABASE_URL/functions/v1/place_detail" \
    -H "apikey: $SUPABASE_ANON_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"place_id\":\"$place_id\"}" > "$tmp_detail"
else
  echo '{}' > "$tmp_detail"
fi

if rg -n "google_" "$tmp_nearby" "$tmp_plan" "$tmp_detail" >/dev/null; then
  echo "FAIL: Runtime response içinde google_ alanı bulundu" >&2
  rg -n "google_" "$tmp_nearby" "$tmp_plan" "$tmp_detail" || true
  exit 1
fi

echo "OK: Public runtime response'larda google_ alanı yok"
echo "nearby_items=$(jq '.items|length' "$tmp_nearby")"
echo "plan_day1=$(jq '.days_plan[0].stops|length // 0' "$tmp_plan")"

rm -f "$tmp_nearby" "$tmp_plan" "$tmp_detail"
