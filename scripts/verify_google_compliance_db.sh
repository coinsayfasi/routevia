#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ -z "${SUPABASE_URL:-}" || -z "${SUPABASE_SERVICE_ROLE_KEY:-}" ]]; then
  echo "SUPABASE_URL ve SUPABASE_SERVICE_ROLE_KEY gerekli" >&2
  exit 1
fi

audit_json="$(curl -sS -X POST "$SUPABASE_URL/rest/v1/rpc/google_compliance_audit" \
  -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
  -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  -d '{}')"

if [[ -z "$audit_json" ]]; then
  echo "Audit response bos dondu" >&2
  exit 1
fi

echo "$audit_json"

published_google="$(echo "$audit_json" | jq -r '.[] | select(.metric=="places_google_published") | .value')"
non_google_place_id="$(echo "$audit_json" | jq -r '.[] | select(.metric=="places_non_google_with_google_place_id") | .value')"
non_google_rating="$(echo "$audit_json" | jq -r '.[] | select(.metric=="places_non_google_with_google_rating") | .value')"
non_google_url="$(echo "$audit_json" | jq -r '.[] | select(.metric=="places_non_google_with_google_url") | .value')"
non_google_media="$(echo "$audit_json" | jq -r '.[] | select(.metric=="place_media_non_google_google_refs") | .value')"

if [[ "${published_google:-0}" != "0" ]]; then
  echo "FAIL: published google rows var: $published_google" >&2
  exit 1
fi

if [[ "${non_google_place_id:-0}" != "0" ]]; then
  echo "FAIL: non-google rows google_place_id tasiyor: $non_google_place_id" >&2
  exit 1
fi

if [[ "${non_google_rating:-0}" != "0" ]]; then
  echo "FAIL: non-google rows google rating/review tasiyor: $non_google_rating" >&2
  exit 1
fi

if [[ "${non_google_url:-0}" != "0" ]]; then
  echo "FAIL: non-google rows maps.google.com source_url tasiyor: $non_google_url" >&2
  exit 1
fi

if [[ "${non_google_media:-0}" != "0" ]]; then
  echo "FAIL: non-google rows google media refs tasiyor: $non_google_media" >&2
  exit 1
fi

echo "OK: Google compliance DB audit passed"
