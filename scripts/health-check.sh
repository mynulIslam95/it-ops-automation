#!/usr/bin/env bash
# Linux host health check. Exit 0 if all gates pass, 1 if any gate fails.
set -euo pipefail

DISK_LIMIT="${DISK_LIMIT:-90}"
FAILED=0
note() { printf '%s\n' "$*"; }
fail() { note "FAIL: $*"; FAILED=1; }

note "health-check $(date -Iseconds 2>/dev/null || date)"
note "host $(hostname)"
note "---"

if command -v df >/dev/null; then
  while read -r pct mp; do
    n="${pct%%%}"
    if [ "$n" -ge "$DISK_LIMIT" ]; then
      fail "disk ${mp} at ${pct} (limit ${DISK_LIMIT}%)"
    else
      note "OK disk ${mp} ${pct}"
    fi
  done < <(df -P -x tmpfs -x devtmpfs 2>/dev/null | awk 'NR>1 {print $5, $6}')
fi

if command -v free >/dev/null; then
  note "OK memory $(free -h | awk '/Mem:/ {print $3 " used / " $2}')"
elif command -v vm_stat >/dev/null; then
  note "OK memory (darwin) $(vm_stat | head -n 5 | tr '\n' ' ')"
fi

if command -v systemctl >/dev/null; then
  failed_units="$(systemctl --failed --no-legend --plain 2>/dev/null | awk '{print $1}' || true)"
  if [ -n "$failed_units" ]; then
    fail "systemd failed units: $failed_units"
  else
    note "OK systemd: no failed units"
  fi
else
  note "SKIP systemd (not present on this host)"
fi

if command -v ss >/dev/null; then
  note "OK listeners"
  ss -tlnH 2>/dev/null | awk '{print "  " $4}' | head
elif command -v netstat >/dev/null; then
  note "OK listeners"
  netstat -tln 2>/dev/null | awk 'NR>2 {print "  " $4}' | head
fi

if [ "$FAILED" -ne 0 ]; then
  note "---"
  note "result: FAIL"
  exit 1
fi
note "---"
note "result: PASS"
exit 0
