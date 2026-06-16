#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_DIR="$ROOT_DIR/apps/mobile"
RELEASES_DIR="$ROOT_DIR/releases"

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

# iOS/IPA build için RC key zorunlu
if [[ "$TARGET" == "ios" || "$TARGET" == "ipa" ]]; then
  if [[ -z "${REVENUECAT_IOS_KEY:-}" ]]; then
    echo "HATA: REVENUECAT_IOS_KEY .env dosyasında eksik — IAP çalışmaz, App Store reject eder!" >&2
    exit 1
  fi
fi

# Build version from pubspec
VERSION=$(grep '^version:' "$APP_DIR/pubspec.yaml" | head -1 | awk '{print $2}')
VNAME="${VERSION%%+*}"
VCODE="${VERSION##*+}"
OUTFILE_BASE="routevia-v${VNAME}-${VCODE}"

cd "$APP_DIR"

DART_DEFINES=(
  "--dart-define=SUPABASE_URL=$SUPABASE_URL"
  "--dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY"
)

if [[ -n "${REVENUECAT_ANDROID_KEY:-}" ]]; then
  DART_DEFINES+=("--dart-define=REVENUECAT_ANDROID_KEY=$REVENUECAT_ANDROID_KEY")
fi
if [[ -n "${REVENUECAT_IOS_KEY:-}" ]]; then
  DART_DEFINES+=("--dart-define=REVENUECAT_IOS_KEY=$REVENUECAT_IOS_KEY")
fi
if [[ -n "${APP_STORE_URL:-}" ]]; then
  DART_DEFINES+=("--dart-define=APP_STORE_URL=$APP_STORE_URL")
fi
if [[ -n "${ADMOB_REWARDED_ANDROID:-}" ]]; then
  DART_DEFINES+=("--dart-define=ADMOB_REWARDED_ANDROID=$ADMOB_REWARDED_ANDROID")
fi
if [[ -n "${ADMOB_REWARDED_IOS:-}" ]]; then
  DART_DEFINES+=("--dart-define=ADMOB_REWARDED_IOS=$ADMOB_REWARDED_IOS")
fi
if [[ -n "${ADMOB_APP_OPEN_ANDROID:-}" ]]; then
  DART_DEFINES+=("--dart-define=ADMOB_APP_OPEN_ANDROID=$ADMOB_APP_OPEN_ANDROID")
fi
if [[ -n "${ADMOB_APP_OPEN_IOS:-}" ]]; then
  DART_DEFINES+=("--dart-define=ADMOB_APP_OPEN_IOS=$ADMOB_APP_OPEN_IOS")
fi

mkdir -p "$RELEASES_DIR"

case "$TARGET" in
  android)
    echo ">>> Building APK (release) — v$VERSION..."
    flutter build apk --release "${DART_DEFINES[@]}"
    cp "$APP_DIR/build/app/outputs/flutter-apk/app-release.apk" "$RELEASES_DIR/${OUTFILE_BASE}.apk"
    echo "APK: $RELEASES_DIR/${OUTFILE_BASE}.apk"
    ;;
  aab)
    echo ">>> Building AAB (release) — v$VERSION..."
    flutter build appbundle --release "${DART_DEFINES[@]}"
    cp "$APP_DIR/build/app/outputs/bundle/release/app-release.aab" "$RELEASES_DIR/${OUTFILE_BASE}.aab"
    echo "AAB: $RELEASES_DIR/${OUTFILE_BASE}.aab"
    ;;
  both)
    echo ">>> Building APK + AAB (release) — v$VERSION..."
    flutter build apk --release "${DART_DEFINES[@]}"
    cp "$APP_DIR/build/app/outputs/flutter-apk/app-release.apk" "$RELEASES_DIR/${OUTFILE_BASE}.apk"
    flutter build appbundle --release "${DART_DEFINES[@]}"
    cp "$APP_DIR/build/app/outputs/bundle/release/app-release.aab" "$RELEASES_DIR/${OUTFILE_BASE}.aab"
    echo "APK: $RELEASES_DIR/${OUTFILE_BASE}.apk"
    echo "AAB: $RELEASES_DIR/${OUTFILE_BASE}.aab"
    ;;
  ios)
    echo ">>> Building iOS (release, no-codesign) — v$VERSION..."
    flutter build ios --release --no-codesign "${DART_DEFINES[@]}"
    echo "iOS app: $APP_DIR/build/ios/iphoneos/Runner.app"
    ;;
  ipa)
    echo ">>> Building iOS IPA (App Store) — v$VERSION..."
    flutter build ipa --release \
      --export-options-plist="$APP_DIR/ios/exportOptions-appstore.plist" \
      "${DART_DEFINES[@]}"
    IPA_SRC="$APP_DIR/build/ios/ipa/routevia.ipa"
    IPA_DST="$RELEASES_DIR/${OUTFILE_BASE}.ipa"
    cp "$IPA_SRC" "$IPA_DST"
    echo "IPA: $IPA_DST"
    echo ""
    echo "App Store'a yüklemek için:"
    echo "  xcrun altool --upload-app -f '$IPA_DST' -t ios --apiKey <KEY_ID> --apiIssuer <ISSUER_ID>"
    echo "  veya Xcode > Window > Organizer > Distribute App"
    ;;
  *)
    echo "Usage: scripts/build_mobile_release.sh [android|aab|both|ios|ipa]" >&2
    exit 1
    ;;
esac
