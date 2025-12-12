#!/usr/bin/env bash
# Check if Twingate client is online

# This is a very straight-forward and basic healthcheck that simply runs
# `twingate status` and looks for the "online" status. If found,
# the healthcheck passes. If not, it retries a few times before failing.
set -euo pipefail

# Healthcheck parameters
MAX_RETRIES=5
SLEEP_BETWEEN=5

# Main healthcheck loop
for i in $(seq 1 "$MAX_RETRIES"); do
    echo "[healthcheck] Checking Twingate status (attempt $i of $MAX_RETRIES)..."
    if twingate status | grep -q "online"; then
        echo "[healthcheck] Twingate is online."
        exit 0
    else
        echo "[healthcheck] Twingate is not online. Retrying in $SLEEP_BETWEEN seconds..."
        sleep "$SLEEP_BETWEEN"
    fi
done

echo "[healthcheck] Twingate did not become online after $MAX_RETRIES attempts."
exit 1