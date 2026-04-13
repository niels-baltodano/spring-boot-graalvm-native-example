---
name: agents
description: Always-loaded project anchor. Read this first. Contains project identity, non-negotiables, commands, and pointer to ROUTER.md for full context.
last_updated: 2026-04-12
---

# Spring Boot GraalVM Native Example

## What This Is
A Spring Boot application optimized for GraalVM Native Image compilation, delivering faster startup times and reduced memory footprint.

## Non-Negotiables
- Java 21 required for all compilation and runtime
- Native Image builds require GraalVM 22.3+ with `native-image` installed
- Never commit secrets or API keys
- Always run tests before native compilation: `./mvnw -ntp verify`
- Use Maven wrapper (`./mvnw`) for all builds, not system Maven

## Commands
- Dev: `./mvnw spring-boot:run`
- Test: `./mvnw -ntp verify`
- Native Build: `./mvnw native:compile -B -ntp -Pnative,prod -DskipTests`
- Java Lint: `./mvnw checkstyle:check`
- Kotlin Lint: `./mvnw detekt:check -Ddetekt.config=detekt.yml`
- SonarQube: `./mvnw -Psonar compile initialize sonar:sonar`
- Javadoc: `./mvnw javadoc:javadoc`
- Dokka: `./mvnw dokka:dokka`
- Docker Build: `docker build -t spring-boot-graalvm-samples .`
- Docker Run: `docker run -d -p 8080:8080 spring-boot-graalvm-samples`

## After Every Task
After completing any task: update `.mex/ROUTER.md` project state and any `.mex/` files that are now out of date. If no pattern existed for the task you just completed, create one in `.mex/patterns/`.

## Navigation
At the start of every session, read `.mex/ROUTER.md` before doing anything else.
For full project context, patterns, and task guidance — everything is there.
