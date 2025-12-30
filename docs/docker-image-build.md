# Building Custom Temporal Docker Image for TiDB

This guide explains how to build a custom Temporal server Docker image that is fully compatible with TiDB for production.

## Why a Custom Build?

TiDB does not support MySQL's `LOCK IN SHARE MODE` syntax. While you can enable `tidb_enable_noop_functions` as a workaround, this removes critical data integrity guarantees and is **not recommended for production**.

The proper solution is to build a custom Temporal Docker image with `LOCK IN SHARE MODE` removed from the source code.(Already patched)


## Step 1: Create Dockerfile

The Temporal repository includes build tooling but not a Dockerfile. Create one:

```bash
cat > Dockerfile << 'EOF'
# Multi-stage build for Temporal Server with TiDB support
FROM golang:1.21-alpine AS builder

# Install build dependencies
RUN apk add --no-cache git make

# Set working directory
WORKDIR /temporal

# Copy source code
COPY . .

# Build the server binary
RUN make temporal-server

# Final stage - minimal runtime image
FROM alpine:3.18

# Install runtime dependencies
RUN apk add --no-cache ca-certificates tzdata

# Copy binary from builder
COPY --from=builder /temporal/temporal-server /usr/local/bin/

# Copy config directory
COPY --from=builder /temporal/config /etc/temporal/config/
COPY --from=builder /temporal/schema /etc/temporal/schema/

# Set environment
ENV TEMPORAL_HOME=/etc/temporal
WORKDIR /etc/temporal

# Expose ports
# 6933-6939: Membership (Ringpop)
# 7233-7239: gRPC
EXPOSE 6933 6934 6935 6936 6939
EXPOSE 7233 7234 7235 7236 7239

# Run server
ENTRYPOINT ["/usr/local/bin/temporal-server"]
CMD ["start"]
EOF
```

## Step 2: Build the Docker Image

Build the image with a version tag:

```bash
# Build with version tag
docker build -t temporal-tidb:1.28.1 .

# Tag for your registry
# For Docker Hub:
docker tag temporal-tidb:1.28.1 <your-dockerhub-username>/temporal-tidb:1.28.1

# For private registry:
docker tag temporal-tidb:1.28.1 <your-registry>/temporal-tidb:1.28.1
```

The build will take 5-10 minutes.

## Step 3: Test the Image Locally

Before pushing, test the image:

```bash
# Run a test container
docker run --rm temporal-tidb:1.28.1 --version

# Expected output: Temporal server version info
```
## Step 4: Push to Registry

### Docker Hub

```bash
# Login
docker login

# Push
docker push ghcr.io/gaimin-io-limited/temporal-tidb:1.28.1
```

## Maintenance

### Rebuilding After Code Changes

```bash
# Rebuild with new tag (use date or commit hash)
docker build -t temporal-tidb:1.28.1-$(date +%Y%m%d) .

# Push and update Helm values
docker push <registry>/temporal-tidb:1.28.1-$(date +%Y%m%d)
```

## Troubleshooting

### Build Fails

If the build fails with Go errors:
- Ensure Go version matches Temporal requirements (check go.mod)
- Check that all source files are present
- Verify no syntax errors in patched files

### Runtime Errors

If pods crash after deploying custom image:
- Check logs: `kubectl logs -n <temporal-namespace> deployment/temporal-dev-history`
- Verify the image was built correctly: `docker run --rm <image> --version`
- Ensure all required files (config, schema) are in the image

### Database Errors

If you see TiDB-related errors:
- Verify the patches were applied correctly
- Check no `LOCK IN SHARE MODE` remains: `grep -r "LOCK IN SHARE MODE" common/`
- Ensure TiDB connection settings are correct in values.yaml
