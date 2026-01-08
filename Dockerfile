# Multi-stage build for Temporal Server with TiDB support
FROM docker.io/library/golang:1.25-alpine AS builder

# Install build dependencies
RUN apk add --no-cache git make

# Set working directory
WORKDIR /temporal

# Copy source code
COPY . .

# Build the server binary
RUN make temporal-server

# Final stage - minimal runtime image
FROM docker.io/library/alpine:3.18

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
