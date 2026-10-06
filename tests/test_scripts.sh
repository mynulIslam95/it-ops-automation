#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
chmod +x "$ROOT/scripts/"*.sh
"$ROOT/scripts/health-check.sh"
ARCHIVE="$("$ROOT/scripts/backup-folder.sh" | tail -n 1)"
"$ROOT/scripts/restore-folder.sh" "$ARCHIVE" "$ROOT/evidence/restored-test"
test -f "$ROOT/evidence/restored-test/office-share/welcome.txt"
echo "tests passed"
