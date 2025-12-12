#!/usr/bin/env bash
set -euo pipefail

KEY_DIR="${KEY_DIR:-/etc/twingate-service-key}"
KEY_FILE="${KEY_FILE:-$KEY_DIR/service-key.json}"

log_with_timestamp() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $@"
}

log_with_timestamp "[entrypoint] Starting Twingate headless client container..."

mkdir -p "$KEY_DIR"

# Write multi-line JSON from env var into the service key file
if [[ -n "${TWINGATE_SERVICE_KEY:-}" ]]; then
    log_with_timestamp "[entrypoint] Writing service key JSON from TWINGATE_SERVICE_KEY env var..."
    # Preserve newlines as-is
    printf "%s" "$TWINGATE_SERVICE_KEY" > "$KEY_FILE"
else
    log_with_timestamp "[entrypoint] ERROR: TWINGATE_SERVICE_KEY environment variable is not set."
    log_with_timestamp "[entrypoint] Provide the multi-line JSON in docker-compose.yml using a literal block."
    exit 1
fi

if [[ ! -s "$KEY_FILE" ]]; then
    log_with_timestamp "[entrypoint] ERROR: service-key.json is missing or empty at $KEY_FILE"
    exit 1
fi

log_with_timestamp "[entrypoint] Running 'twingate setup --headless'..."
twingate setup --headless "$KEY_FILE"

log_with_timestamp "[entrypoint] Setting log level to debug..."
twingate config log-level debug

log_with_timestamp "[entrypoint] Starting Twingate service..."
twingate start

log_with_timestamp "[entrypoint] Initial status:"
twingate status || true

CRON_FILE=/etc/cron.d/tg-healthchecks
cat <<'EOF' > "$CRON_FILE"
*/5 * * * * root /usr/local/bin/healthchecks.sh >> /var/log/healthchecks.log 2>&1
EOF
chmod 0644 "$CRON_FILE"

# Start cron in the background (Debian's cron daemon)
#/usr/sbin/cron

log_with_timestamp "[entrypoint] Twingate started. Keeping container running."
# Keep container alive; twingate runs as a daemon
sleep infinity
