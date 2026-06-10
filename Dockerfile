###############################################################################
#  Multi-arch Dockerfile: dufs + material-assets UI
#  Build with:  docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 .
#
#  Runtime environment variables (all optional):
#    DUFS_SERVE_PATH  – path to serve          (default: /data)
#    DUFS_PORT        – listen port            (default: 5000)
#    DUFS_BIND        – bind address           (default: 0.0.0.0)
#    DUFS_ALLOW_ALL   – enable all operations  (default: false)
#    DUFS_AUTH        – access control rules   (e.g. "user:pass@/:rw")
#    ... any other DUFS_* env vars supported by dufs
###############################################################################

# ── 1. Builder: download pre-built binaries (runs natively on build host) ────
FROM --platform=$BUILDPLATFORM alpine:3.22 AS builder

ARG DUFS_VERSION=0.46.0
ARG TARGETARCH
ARG TARGETVARIANT

RUN apk add --no-cache curl bash

# Download dufs binary for the target architecture
RUN set -eux; \
    case "${TARGETARCH}" in \
      amd64)  RUST_TARGET="x86_64-unknown-linux-musl"  ;; \
      arm64)  RUST_TARGET="aarch64-unknown-linux-musl"  ;; \
      arm)    RUST_TARGET="armv7-unknown-linux-musleabihf" ;; \
      *)      echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac; \
    URL="https://github.com/sigoden/dufs/releases/download/v${DUFS_VERSION}/dufs-v${DUFS_VERSION}-${RUST_TARGET}.tar.gz"; \
    echo "Downloading dufs from: ${URL}"; \
    curl -fsSL "${URL}" | tar xz -C /tmp; \
    mv /tmp/dufs /usr/local/bin/dufs; \
    chmod +x /usr/local/bin/dufs

# Download & extract material-assets (platform-independent)
RUN curl -fsSL \
      "https://github.com/TransparentLC/dufs-material-assets/releases/download/v${DUFS_VERSION}/dufs-material-assets-embed.zip" \
      -o /tmp/assets.zip && \
    mkdir -p /opt/dufs/assets && \
    unzip -q /tmp/assets.zip -d /opt/dufs/assets && \
    rm /tmp/assets.zip

# Create entrypoint script
RUN cat > /opt/dufs/entrypoint.sh << 'EOF'
#!/bin/sh
set -e

: "${DUFS_SERVE_PATH:=/data}"
: "${DUFS_PORT:=5000}"
: "${DUFS_BIND:=0.0.0.0}"

set -- /usr/local/bin/dufs "${DUFS_SERVE_PATH}" \
  --assets /opt/dufs/assets \
  --port "${DUFS_PORT}" \
  --bind "${DUFS_BIND}"

[ -n "${DUFS_ALLOW_ALL}" ] && set -- "$@" --allow-all
[ -n "${DUFS_AUTH}" ]       && set -- "$@" --auth "${DUFS_AUTH}"

exec "$@"
EOF
RUN chmod +x /opt/dufs/entrypoint.sh

# ── 2. Final image: minimal scratch-based ────────────────────────────────────
FROM scratch

COPY --from=builder /usr/local/bin/dufs          /usr/local/bin/dufs
COPY --from=builder /opt/dufs/assets             /opt/dufs/assets
COPY --from=builder /opt/dufs/entrypoint.sh      /opt/dufs/entrypoint.sh
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

EXPOSE 5000
VOLUME ["/data"]

ENTRYPOINT ["/opt/dufs/entrypoint.sh"]
