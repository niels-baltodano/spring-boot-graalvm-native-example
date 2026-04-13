---
name: docker-compose
description: Pattern for docker-compose.yml configuration, env vars, health checks, and runtime tuning
---

# Docker Compose Pattern

## Commands
```bash
docker compose up -d --build    # Build + run
docker compose down             # Stop + remove
docker compose logs -f          # Follow logs
```

## Configurable Env Vars
| Var | Default | Purpose |
|-----|---------|---------|
| `TAG` | `latest` | Image tag |
| `APP_PORT` | `8080` | Host port mapping |
| `APP_CPU_LIMIT` | `1.0` | CPU limit |
| `APP_MEMORY_LIMIT` | `512M` | Memory limit |

### Override Example
```bash
TAG=v1 APP_PORT=9090 docker compose up -d --build
```

## Architecture

### YAML Anchors
- **`x-defaults`** — shared config: platform, restart, network, log rotation
- **`x-healthcheck`** — shared health check params: interval 30s, timeout 10s, retries 5, start_period 10s
- **`x-app-base`** — merges `x-defaults` + sets image name/tag

### Service: `spring-boot-graalvm-native`
- Builds from local `Dockerfile`
- Inherits `x-app-base`
- Health check: `CMD /app/application -XX:+PrintFlagsFinal -version` (works in distroless, no shell needed)
- Resource limits: `APP_CPU_LIMIT` CPUs, `APP_MEMORY_LIMIT` memory
- Port: `${APP_PORT:-8080}:8080`

### Networking
- Bridge network: `spring-graalvm_net`
- Isolated from other compose projects

### Logging
- Driver: `json-file`
- Rotation: 10m max per file, 3 files max

### Platform
- Forced to `linux/amd64` — required for Apple Silicon hosts running amd64 native images

### Restart Policy
- `unless-stopped` — auto-restarts unless explicitly stopped

## Notes
- Health check uses `-XX:+PrintFlagsFinal -version` because distroless has no shell — this JVM flag exits 0 and confirms the binary runs
- `env_file: .env` line commented out but ready to enable