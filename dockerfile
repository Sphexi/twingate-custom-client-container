# Dockerfile
FROM debian:bookworm-slim

# Install runtime dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       curl \
       ca-certificates \
       bash \
       iproute2 \
       iptables \
       iputils-ping \
       procps \
       grep \
       busybox \
    && rm -rf /var/lib/apt/lists/* \
    && ln -s /bin/busybox /sbin/crond


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
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
