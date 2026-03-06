#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_DIR="$ROOT_DIR/apps/mobile"

if [[ ! -f "$ROOT_DIR/.env" ]]; then
  echo "Missing .env in project root: $ROOT_DIR/.env" >&2
  exit 1
fi

set -a
source "$ROOT_DIR/.env"
set +a

if [[ -z "${SUPABASE_URL:-}" || -z "${SUPABASE_ANON_KEY:-}" ]]; then
  echo "SUPABASE_URL / SUPABASE_ANON_KEY missing in .env" >&2
  exit 1
fi

TARGET="${1:-android}"

cd "$APP_DIR"

case "$TARGET" in
  android)
    flutter build apk --release \
      --dart-define="SUPABASE_URL=$SUPABASE_URL" \
      --dart-define="SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY"
    echo "APK: $APP_DIR/build/app/outputs/flutter-apk/app-release.apk"
    ;;
  ios)
    flutter build ios --release --no-codesign \
      --dart-define="SUPABASE_URL=$SUPABASE_URL" \
      --dart-define="SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY"
    echo "iOS app: $APP_DIR/build/ios/iphoneos/Runner.app"
    ;;
  *)
    echo "Usage: scripts/build_mobile_release.sh [android|ios]" >&2
    exit 1
    ;;
esac
