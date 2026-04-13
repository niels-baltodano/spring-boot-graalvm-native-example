---
name: native-build
description: Pattern for building and troubleshooting GraalVM Native Image compilations
---

# Native Build Pattern

## Prerequisites Check
```bash
java -version                    # Must show Java 21
native-image --version           # Must show GraalVM 22.3+
```

## Standard Native Build
```bash
./mvnw native:compile -B -ntp -Pnative,prod -DskipTests
```

## If Build Fails
1. Check for missing native-image dependencies in pom.xml
2. Verify GraalVM is correctly installed and JAVA_HOME points to it
3. Look for reflection/proxy issues in build output

## Post-Build Verification
```bash
./target/native-executable       # Test the native binary
curl http://localhost:8080/api/v1/hello
```

## Compression (Optional)
```bash
upx --ultra-brute --lzma target/native-executable
```
