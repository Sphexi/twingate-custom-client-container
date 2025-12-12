#!/usr/bin/env bash
set -euo pipefail

KEY_DIR="${KEY_DIR:-/etc/twingate-service-key}"
KEY_FILE="${KEY_FILE:-$KEY_DIR/service-key.json}"

echo "[entrypoint] Starting Twingate headless client container..."

mkdir -p "$KEY_DIR"

# Write multi-line JSON from env var into the service key file
if [[ -n "${TWINGATE_SERVICE_KEY:-}" ]]; then
    echo "[entrypoint] Writing service key JSON from TWINGATE_SERVICE_KEY env var..."
    # Preserve newlines as-is
    printf "%s" "$TWINGATE_SERVICE_KEY" > "$KEY_FILE"
else
    echo "[entrypoint] ERROR: TWINGATE_SERVICE_KEY environment variable is not set."
    echo "[entrypoint] Provide the multi-line JSON in docker-compose.yml using a literal block."
    exit 1
fi

if [[ ! -s "$KEY_FILE" ]]; then
    echo "[entrypoint] ERROR: service-key.json is missing or empty at $KEY_FILE"
    exit 1
fi

echo "[entrypoint] Running 'twingate setup --headless'..."
twingate setup --headless "$KEY_FILE"

echo "[entrypoint] Setting log level to debug..."
twingate config log-level debug

echo "[entrypoint] Starting Twingate service..."
twingate start

echo "[entrypoint] Initial status:"
twingate status || true

# Start cron and register healthcheck job
echo "[entrypoint] Setting up cron healthcheck..."
CRON_FILE=/etc/cron.d/tg-healthchecks
cat <<'EOF' > "$CRON_FILE"
*/5 * * * * root /usr/local/bin/healthchecks.sh >> /var/log/healthchecks.log 2>&1
EOF
chmod 0644 "$CRON_FILE"

# Ensure cron is running (Debian/Ubuntu-style)
service cron start || cron

echo "[entrypoint] Twingate started. Keeping container running."
# Keep container alive; twingate runs as a daemon
sleep infinity
