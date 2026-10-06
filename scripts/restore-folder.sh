#!/usr/bin/env bash
# Restore a tar.gz backup into a target directory and list recovered files.
set -euo pipefail
ARCHIVE="${1:?usage: restore-folder.sh <archive.tar.gz> [target-dir]}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="${2:-$ROOT/evidence/restored}"
mkdir -p "$TARGET"
tar -tzf "$ARCHIVE" >/dev/null
tar -xzf "$ARCHIVE" -C "$TARGET"
echo "restored into $TARGET"
find "$TARGET" -type f | sort
echo "restore verified: archive listed and extracted"
