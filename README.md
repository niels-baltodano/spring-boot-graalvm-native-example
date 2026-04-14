# Spring Boot GraalVM Native Example

[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=spring-boot-graalvm-native-example&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=spring-boot-graalvm-native-example)
[![Coverage](https://sonarcloud.io/api/project_badges/measure?project=spring-boot-graalvm-native-example&metric=coverage)](https://sonarcloud.io/summary/new_code?id=spring-boot-graalvm-native-example)
![Language](https://img.shields.io/badge/Language-Java-brightgreen)
![Language](https://img.shields.io/badge/Language-Kotlin-brightgreen)
![Framework](https://img.shields.io/badge/Framework-Spring%20Boot-brightgreen)

A lightweight Spring Boot WebFlux application compiled to a GraalVM Native Image for fast startup and low memory usage.

---


## Features

- **Fast startup** — GraalVM Native Image compilation for near-instant boot
- **Low memory** — Minimal footprint with distroless runtime image
- **Reactive** — Spring WebFlux with Kotlin coroutines and Caffeine caching
- **Production-ready** — Actuator health probes, Prometheus metrics, UPX-compressed binary

## Quick Start

**Prerequisites:** Java 21

```bash
git clone https://github.com/susimsek/spring-boot-graalvm-native-example.git
cd spring-boot-graalvm-native-example
./mvnw spring-boot:run
```

The application runs at http://localhost:8080.

### Live Reload

Add `spring-boot-devtools` to `pom.xml` for automatic restarts on code changes:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-devtools</artifactId>
    <scope>runtime</scope>
</dependency>
```

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/hello` | Returns a cached greeting message |
| GET | `/api/v1/todos` | Fetches todos from JSONPlaceholder |
| GET | `/api/v1/todos/{id}` | Fetches a single todo by ID |

Test:

```bash
curl http://localhost:8080/api/v1/hello
```

## Testing

Run unit and integration tests:

```bash
./mvnw -ntp verify
```

## Native Build

**Prerequisites:** Java 21, GraalVM 22.3+ with `native-image`

```bash
./mvnw native:compile -B -ntp -Pnative,prod -DskipTests
```

The executable is at `target/native-executable`.

### Optional: Compress with UPX

```bash
upx --best --lzma target/native-executable
```

## Docker

### Dockerfile

The build uses a two-stage multistage Dockerfile:

**Stage 1 — builder** (`ghcr.io/graalvm/native-image-community:21`):
- Installs `zlib` and `xz` for native compilation and UPX
- Downloads all Maven dependencies offline for cache efficiency
- Compiles the GraalVM Native Image with the `native,prod` Maven profiles
- Extracts shared library dependencies via `ldd` for runtime copying
- Downloads and applies UPX compression (`--best --lzma`) to the binary

**Stage 2 — runtime** (`gcr.io/distroless/base-debian12:nonroot`):
- Copies extracted shared libraries into `/lib/`
- Copies the UPX-compressed native executable
- Runs as non-root user `65532:65532` (distroless nonroot)
- Exposes port `8080`

### Docker Compose (Recommended)

```bash
docker compose up -d --build    # Build + run
docker compose down             # Stop + remove
docker compose logs -f          # Follow logs
```

Environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `TAG` | `latest` | Image tag |
| `APP_PORT` | `8080` | Host port |
| `APP_CPU_LIMIT` | `1.0` | CPU limit |
| `APP_MEMORY_LIMIT` | `512M` | Memory limit |

Override example:

```bash
TAG=v1 APP_PORT=9090 docker compose up -d --build
```

Additional compose defaults:
- **Platform**: `linux/amd64` forced (ensures compatibility on Apple Silicon via Rosetta)
- **Restart policy**: `unless-stopped`
- **Log rotation**: `json-file` driver, max `10m` per file, `3` files retained
- **Health check**: verifies the native binary is executable (interval `30s`, timeout `10s`, 5 retries, `10s` start period)
- **Network**: isolated bridge network `spring-graalvm_net`

### Docker CLI

```bash
docker build -t spring-boot-graalvm-samples .
docker run -d -p 8080:8080 spring-boot-graalvm-samples
```

Build args:

| Argument | Default | Description |
|----------|---------|-------------|
| `NATIVE_MAX_HEAP` | `6g` | JVM max heap during native compilation |
| `UPX_VERSION` | `4.2.4` | UPX version used for binary compression |
| `TARGETARCH` | auto | Target architecture (`amd64` or `arm64`) |

## Deployment

### Production Docker Compose

```bash
docker-compose -f deploy/docker-compose/prod/docker-compose.yml up -d
docker-compose -f deploy/docker-compose/prod/docker-compose.yml down
```

Uses pre-built image `suayb/graalvm-native-app:main`. Health check polls the Actuator readiness endpoint:

```
curl --fail --silent localhost:8080/actuator/health/readiness | grep UP || exit 1
```

### Kubernetes (Helm)

```bash
helm install graalvm-native-app deploy/helm/graalvm-native-app
helm uninstall graalvm-native-app
```

## Code Quality

### Lint

```bash
./mvnw checkstyle:check                       # Java
./mvnw detekt:check -Ddetekt.config=detekt.yml  # Kotlin
```

### SonarQube

```bash
./mvnw -Psonar compile initialize sonar:sonar
```

### Documentation

```bash
./mvnw javadoc:javadoc    # Java → target/reports/apidocs/
./mvnw dokka:dokka        # Kotlin → target/dokka/
```

### Swagger UI

API documentation at http://localhost:8080/swagger-ui.html

## Tech Stack

![Java](https://img.shields.io/badge/Java-21-blue?logo=openjdk&logoColor=white)
![Kotlin](https://img.shields.io/badge/Kotlin-2.1.0-7F52FF?logo=kotlin&logoColor=white)
![Maven](https://img.shields.io/badge/Maven-Build_Automation-C71A36?logo=apachemaven&logoColor=white)
![Spring Boot](https://img.shields.io/badge/Spring_Boot-3.4.1-green?logo=spring&logoColor=white)
![GraalVM](https://img.shields.io/badge/GraalVM-Native_Image-FF8C00?logo=graalvm&logoColor=white)
![Spring Boot WebFlux](https://img.shields.io/badge/Spring_Boot_WebFlux-Reactive_Programming-6DB33F?logo=spring&logoColor=white)
![Spring Boot Actuator](https://img.shields.io/badge/Spring_Boot_Actuator-Monitoring-green?logo=spring&logoColor=white)
![Checkstyle](https://img.shields.io/badge/Checkstyle-Code_Analysis-orange?logo=openjdk&logoColor=white)
![Detekt](https://img.shields.io/badge/Detekt-Code_Analysis-orange?logo=kotlin&logoColor=white)
![Lombok](https://img.shields.io/badge/Lombok-Boilerplate_Code_Reduction-007396?logo=openjdk&logoColor=white)
![MapStruct](https://img.shields.io/badge/MapStruct-Efficient_Object_Mapping-009C89?logo=openjdk&logoColor=white)
![Springdoc](https://img.shields.io/badge/Springdoc-API_Documentation-6DB33F?logo=spring&logoColor=white)
![Caffeine](https://img.shields.io/badge/Caffeine-High_Performance_Cache-C71A36?logo=openjdk&logoColor=white)
![Javadoc](https://img.shields.io/badge/Javadoc-Documentation-007396?logo=openjdk&logoColor=white)
![Dokka](https://img.shields.io/badge/Dokka-Documentation-007396?logo=kotlin&logoColor=white)
![SonarQube](https://img.shields.io/badge/SonarQube-4E9BCD?logo=sonarqube&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&logoColor=white)
![Helm](https://img.shields.io/badge/Helm-0F1689?logo=helm&logoColor=white)
![UPX](https://img.shields.io/badge/UPX-Executable_Compression-0096D6?logo=upx&logoColor=white)
![Bootstrap](https://img.shields.io/badge/Bootstrap-5.3-purple?logo=bootstrap&logoColor=white)
![Font Awesome](https://img.shields.io/badge/Font_Awesome-6.0-339AF0?logo=fontawesome&logoColor=white)
![WebJars Locator Lite](https://img.shields.io/badge/WebJars_Locator_Lite-Dynamic_Asset_Locator-007396?logo=java&logoColor=white)