# Dockerfile
FROM debian:bookworm-slim

# Install runtime dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       cron \
       curl \
       ca-certificates \
       bash \
       iproute2 \
       iptables \
       iputils-ping \
       procps \
       grep \
    && rm -rf /var/lib/apt/lists/* \

# Install Twingate Linux client
RUN curl -fsSL https://binaries.twingate.com/client/linux/install.sh | bash

# Where the service key will be written
ENV KEY_DIR=/etc/twingate-service-key
ENV KEY_FILE=/etc/twingate-service-key/service-key.json
ENV TERM=xterm-256color

# Built-in healthcheck using `twingate status`
#HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
#  CMD twingate status 2>&1 | tee /proc/1/fd/1 | grep -q online || exit 1

# Entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY healthchecks.sh /usr/local/bin/healthchecks.sh
COPY healthchecks.d/ /healthchecks.d/
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/healthchecks.sh \
    && find /healthchecks.d -type f -name '*.sh' -exec chmod +x {} \;

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
