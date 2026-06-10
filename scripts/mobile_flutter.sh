#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_DIR="$ROOT_DIR/apps/mobile"

if [[ ! -d "$APP_DIR" || ! -f "$APP_DIR/pubspec.yaml" ]]; then
  echo "Flutter app not found at: $APP_DIR" >&2
  exit 1
fi

if [[ $# -eq 0 ]]; then
  cat >&2 <<'EOF'
Usage:
  scripts/mobile_flutter.sh pub get
  scripts/mobile_flutter.sh analyze
  scripts/mobile_flutter.sh test
  scripts/mobile_flutter.sh build apk --release
EOF
  exit 1
fi

cd "$APP_DIR"
exec flutter "$@"
