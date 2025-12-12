#!/usr/bin/env bash
set -euo pipefail

FAILED=0

for f in /healthchecks.d/*.sh; do
  [ -f "$f" ] || continue
  [ -x "$f" ] || chmod +x "$f"

  echo "[healthchecks] Running $f..."
  if ! "$f"; then
    echo "[healthchecks] $f FAILED"
    FAILED=1
  else
    echo "[healthchecks] $f OK"
  fi
done

if [ "$FAILED" -ne 0 ]; then
  echo "[healthchecks] One or more checks failed. Forcing container restart by killing PID 1."
  kill -TERM 1 || kill -KILL 1
fi