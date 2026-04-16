# Stage 1: Build native image with GraalVM -1
FROM ghcr.io/graalvm/native-image-community:21 AS builder

# hadolint: DL4006 - pipefail before RUN with pipes
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Locale UTF-8 sin depender de glibc-langpack#
ENV LC_ALL=C.UTF-8 LANG=C.UTF-8

WORKDIR /app

# hadolint: DL3059 - consolidate RUN
RUN microdnf install -y zlib xz && microdnf clean all

COPY .mvn/ .mvn/
COPY mvnw pom.xml ./

RUN chmod +x mvnw && ./mvnw dependency:go-offline -B -ntp

COPY src/ src/

ARG UPX_VERSION=4.2.4
ARG TARGETARCH
ARG NATIVE_MAX_HEAP=6g

RUN ./mvnw native:compile -B -ntp -Pnative,prod -DskipTests \
    -Dnative-build-args="--verbose -J-Xmx${NATIVE_MAX_HEAP}" && \
    mkdir -p /runtime-libs && \
    ldd target/native-executable | awk '/=>/ && $3!="" {print $3}' | \
    while read -r lib; do cp -v "$lib" /runtime-libs/; done && \
    UPX_ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "arm64_linux" || echo "amd64_linux") && \
    curl -fsSL "https://github.com/upx/upx/releases/download/v${UPX_VERSION}/upx-${UPX_VERSION}-${UPX_ARCH}.tar.xz" | \
    tar -xJ --strip-components=1 -C /usr/local/bin "upx-${UPX_VERSION}-${UPX_ARCH}/upx" && \
    upx --best --lzma target/native-executable

# Stage 2: Minimal runtime
FROM gcr.io/distroless/base-debian12:nonroot

WORKDIR /app

COPY --from=builder /runtime-libs/* /lib/
COPY --from=builder /usr/bin/curl /usr/bin/curl
COPY --from=builder /app/target/native-executable ./application

EXPOSE 8080

USER 65532:65532

ENTRYPOINT ["./application"]
