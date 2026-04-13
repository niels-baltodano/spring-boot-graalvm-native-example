---
name: docker-build
description: Pattern for building and running the multistage Dockerfile with GraalVM native compilation
---

# Docker Build Pattern

## Docker
```bash
docker build -t spring-boot-graalvm-samples .
docker run -d -p 8080:8080 spring-boot-graalvm-samples
```

### Custom Build Args
```bash
docker build --build-arg NATIVE_MAX_HEAP=8g --build-arg UPX_VERSION=4.2.4 -t spring-boot-graalvm-samples .
```

## Test
```bash
curl http://localhost:8080/api/v1/hello
```

## Stop & Remove
```bash
docker stop <container-id>
docker rm <container-id>
```

## Dockerfile Architecture

### Stage 1: Builder (`ghcr.io/graalvm/native-image-community:21`)
- Installs zlib, xz for UPX decompression
- Caches Maven deps first (`COPY .mvn/ pom.xml` before `src/`)
- Compiles native image with `NATIVE_MAX_HEAP` arg (default 6g)
- Extracts runtime dynamic libs via `ldd` → `/runtime-libs/`
- Downloads UPX, compresses binary with `--best --lzma`
- Hadolint compliant (DL4006 pipefail, DL3059 consolidated RUN)

### Stage 2: Runtime (`gcr.io/distroless/base-debian12:nonroot`)
- Copies dynamic libs from builder → `/lib/`
- Copies `curl` from builder for health checks
- Runs as non-root user (65532:65532)
- Exposes port 8080

## Notes
- No Java/GraalVM needed on host for Docker builds
- UPX arch auto-detected via `TARGETARCH` build arg
- Binary compressed ~60-70% smaller with UPX `--best --lzma`