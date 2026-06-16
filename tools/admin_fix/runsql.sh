#!/usr/bin/env bash
set -euo pipefail
RAW=$(security find-generic-password -s "Supabase CLI" -w 2>/dev/null)
export SUPA_PAT=$(printf '%s' "${RAW#go-keyring-base64:}" | base64 -d 2>/dev/null)
python3 "$(dirname "$0")/runsql.py" "$1"
