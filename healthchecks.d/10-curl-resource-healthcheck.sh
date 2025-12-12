#!/usr/bin/env bash
# Run a curl against a specified resource to check connectivity via Twingate

# As an example the FQDN used is "example.internal", replace this with a resource
# that is only accessible via Twingate.

# Alternatively, you can create a resource in your own Twingate tenant with the
# address of whatever you want, and an alias of "example.internal", and this 
# healthcheck will work as-is. As long as it is able to be accessed via 
# curl it should work.

# The point of this healthcheck is to verify that Twingate is routing traffic
# correctly via either a FQDN address or alias that is only resolvable via Twingate.
set -euo pipefail

# Healthcheck parameters
datetime="date +%Y-%m-%d %H:%M:%S%z"
MAX_RETRIES=3
SLEEP_BETWEEN=5

# Main healthcheck loop
for i in $(seq 1 "$MAX_RETRIES"); do
    echo "[healthcheck] $datetime - Checking Resource example.internal status (attempt $i of $MAX_RETRIES)..."
    if curl -s --max-time 10 http://example.internal >/dev/null; then
        echo "[healthcheck] $datetime - Resource example.internal is reachable via Twingate."
        exit 0
    else
        echo "[healthcheck] $datetime - Resource example.internal is not reachable. Retrying in $SLEEP_BETWEEN seconds..."
        sleep "$SLEEP_BETWEEN"
    fi
done

echo "[healthcheck] $datetime - Twingate did not become online after $MAX_RETRIES attempts."
exit 1