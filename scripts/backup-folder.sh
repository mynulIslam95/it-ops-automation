#!/usr/bin/env bash
# Tar a test folder. Default source is fixtures/office-share.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="${1:-$ROOT/fixtures/office-share}"
DEST_DIR="${2:-$ROOT/evidence}"
STAMP="$(date +%Y%m%d-%H%M%S)"
mkdir -p "$DEST_DIR"
OUT="$DEST_DIR/office-share-$STAMP.tar.gz"
tar -czf "$OUT" -C "$(dirname "$SRC")" "$(basename "$SRC")"
echo "backup $OUT"
ls -l "$OUT"
echo "$OUT"
