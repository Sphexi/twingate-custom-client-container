# Twingate Linux Headless Client (Docker Image)

This image provides a lightweight, self-contained way to run the **Twingate Linux Client in headless mode** using a Service Key. It exists to simplify deployments where the regular Connector is not appropriate—such as lightweight gateways, utility containers, or environments where the client must run alongside other services. Instead of mounting a Service Key file, you paste the multi-line JSON directly into `docker-compose.yml`, and the container configures itself automatically on startup.

The idea of this container is that you can run it as a sidecar container alongside other services that need Twingate access. For example, you might run [Uptime Kuma](https://github.com/louislam/uptime-kuma) or [Gatus](https://gatus.io/), services that are used to remotely monitor your infrastructure, and need Twingate access to reach internal resources.

---

## Usage

### 1. Get your Service Key  
In the Twingate Admin Console, create a **Service** and generate a **Service Key**. Copy the JSON exactly as provided.

### 2. Example `docker-compose.yml`
```yaml
version: "3.8"

services:
  tg-headless-client:
    image: ghcr.io/sphexi/twingate-custom-client-container:latest
    privileged: true

    environment:
      TWINGATE_SERVICE_KEY: | # Replace with your Twingate service key JSON
        {
          "host": "example.twingate.com",
          "client_id": "YOUR_CLIENT_ID",
          "client_secret": "YOUR_CLIENT_SECRET",
          "id": "YOUR_SERVICE_KEY_ID"
        }

    devices:
      - /dev/net/tun
    cap_add:
      - NET_ADMIN
    tty: true
    restart: unless-stopped
```

### 3. Start the client

```bash
docker compose up -d
docker compose logs -f tg-headless-client
```

### 4. Access the container

```bash
docker compose exec -it tg-headless-client bash
twingate status
```
