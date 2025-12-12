#!/usr/bin/env bash
set -euo pipefail

datetime=`date "+%Y-%m-%d %H:%M:%S%z"`
FAILED=0

for f in /healthchecks.d/*.sh; do
  [ -f "$f" ] || continue
  [ -x "$f" ] || chmod +x "$f"

  echo "[healthchecks] $datetime - Running $f..."
  if ! "$f"; then
    echo "[healthchecks] $datetime - $f FAILED"
    FAILED=1
  else
    echo "[healthchecks] $datetime - $f OK"
  fi
done

if [ "$FAILED" -ne 0 ]; then
  echo "[healthchecks] $datetime - One or more checks failed. Marking container unhealthy."
  exit 1
fi