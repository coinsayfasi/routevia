#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

fail() {
  echo "[COMPLIANCE][FAIL] $1" >&2
  exit 1
}

echo "[COMPLIANCE] Google footprint scan..."

# 1) Mobile footprint must not include Google Maps/Places SDK traces
if rg -n "GOOGLE_MAPS_ANDROID_API_KEY|com.google.android.geo.API_KEY|google_maps_flutter|maps.googleapis|GoogleMaps|GMS" apps/mobile -S >/tmp/compliance_mobile_hits.txt; then
  echo "[COMPLIANCE] Mobile hits:" >&2
  cat /tmp/compliance_mobile_hits.txt >&2
  fail "Mobile Google SDK/key footprint detected"
fi

# 2) Public runtime functions must stay disabled-by-policy for legacy Google endpoints
for fn in ingest_google_district google_place_enrich cache_google_thumbnails photo_proxy; do
  f="supabase/functions/${fn}/index.ts"
  [[ -f "$f" ]] || fail "Missing function file: $f"
  rg -n "disabled_by_policy|410" "$f" -S >/dev/null || fail "Legacy Google function is not hard-disabled: $fn"
done

# 3) Public mobile data access should stay POI clean layer
if rg -n "from\('places'\)|from\(\"places\"\)" apps/mobile/lib/src/data -S >/tmp/compliance_mobile_places_hits.txt; then
  echo "[COMPLIANCE] Mobile clean-layer violation:" >&2
  cat /tmp/compliance_mobile_places_hits.txt >&2
  fail "Mobile repository reads legacy places table"
fi

# 4) Optional runtime smoke test if env available
if [[ -n "${SUPABASE_URL:-}" && -n "${SUPABASE_ANON_KEY:-}" ]]; then
  echo "[COMPLIANCE] Runtime smoke test..."
  bash scripts/verify_no_google_runtime.sh || fail "Runtime smoke test failed"
else
  echo "[COMPLIANCE] SUPABASE_URL/ANON not set, runtime smoke skipped"
fi

echo "[COMPLIANCE][PASS]"
