# Project State

**Last Updated**: 2026-04-13

## Current Focus
- Docker multistage build for GraalVM native compilation

## Recent Changes
- Initialized `.mex/` directory structure for project context
- Multistage Dockerfile working: GraalVM builder with zlib → distroless runtime with dynamic libs
- Created docker-compose.yml for one-command build + deploy
- Verified Dockerfile + compose working end-to-end
- Updated README.md: added Dockerfile stage breakdown, compose defaults (amd64 platform, log rotation, health check, network), clarified build args and prod health check

## Open Questions
- None

## Decisions
- Using Maven wrapper (`./mvnw`) for all build commands
- GraalVM Native Image compilation requires Java 21 + GraalVM 22.3+
- UPX compression applied in Docker build for smaller binaries
- distroless nonroot base for minimal attack surface
- amd64 platform forced in compose for Apple Silicon compatibility

## Patterns
- [native-build](patterns/native-build.md) — local GraalVM native compilation
- [docker-build](patterns/docker-build.md) — Dockerfile multistage build, UPX, runtime
- [docker-compose](patterns/docker-compose.md) — Compose config, env vars, health checks