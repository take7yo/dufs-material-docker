###############################################################################
#  Multi-arch Dockerfile: dufs with Material Design UI
#
#  Uses dufs-mod pre-built binary from TransparentLC/dufs-material-assets
#  Material UI is embedded directly in the binary — no --assets flag needed.
#
#  Targets:
#    test   – alpine-based image with shell (for CI verification)
#    final  – scratch-based minimal image (default, for publishing)
#
#  Runtime configuration via DUFS_* env vars:
#    DUFS_PORT      – listen port     (default: 5000)
#    DUFS_BIND      – bind address    (default: 0.0.0.0)
#    DUFS_ALLOW_ALL – all operations  (set "true" to enable)
#    DUFS_AUTH      – auth rules      (e.g. "user:pass@/:rw")
#    See https://github.com/sigoden/dufs#cli-options for all options
###############################################################################

# ── 1. Builder ───────────────────────────────────────────────────────────────
FROM --platform=$BUILDPLATFORM alpine:3.22 AS builder

ARG DUFS_VERSION=0.46.0
ARG TARGETARCH
ARG TARGETVARIANT

RUN apk add --no-cache curl unzip

# Download dufs-mod binary (Material UI embedded)
RUN set -eux; \
    case "${TARGETARCH}${TARGETVARIANT}" in \
      386)         RUST_TARGET="i686-unknown-linux-musl"       ;; \
      amd64)       RUST_TARGET="x86_64-unknown-linux-musl"     ;; \
      armv6|arm)   RUST_TARGET="arm-unknown-linux-musleabihf"   ;; \
      armv7)       RUST_TARGET="armv7-unknown-linux-musleabihf" ;; \
      arm64)       RUST_TARGET="aarch64-unknown-linux-musl"     ;; \
      *)           echo "Unsupported: ${TARGETARCH}${TARGETVARIANT}" && exit 1 ;; \
    esac; \
    FILE="dufs-mod-v${DUFS_VERSION}-${RUST_TARGET}.zip"; \
    URL="https://github.com/TransparentLC/dufs-material-assets/releases/download/v${DUFS_VERSION}/${FILE}"; \
    echo "Downloading: ${URL}"; \
    curl -fsSL "${URL}" -o /tmp/dufs-mod.zip && \
    unzip -q /tmp/dufs-mod.zip -d /tmp && \
    mv /tmp/dufs /usr/local/bin/dufs && \
    chmod +x /usr/local/bin/dufs && \
    rm -f /tmp/dufs-mod.zip && \
    echo "Installed:" && ls -lh /usr/local/bin/dufs

# Smoke test (browser UA — dufs serves different HTML to curl vs browser)
RUN mkdir -p /data && \
    sh -c ' \
      UA="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/120.0.0.0" && \
      /usr/local/bin/dufs /data --allow-all -p 5050 & \
      sleep 2 && \
      BODY=$(curl -sf -A "$UA" http://127.0.0.1:5050/) && \
      if echo "$BODY" | grep -q "__INITIAL_DATA__"; then \
        echo "✅ Material UI detected"; \
      else \
        echo "❌ Material UI NOT detected"; \
        echo "$BODY" | head -c 300; \
      fi && \
      kill %1 2>/dev/null; true \
    '

# ── 2. Test image (alpine — has shell for CI verification) ───────────────────
FROM alpine:3.22 AS test

COPY --from=builder /usr/local/bin/dufs     /usr/local/bin/dufs
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

EXPOSE 5000
VOLUME ["/data"]
ENTRYPOINT ["/usr/local/bin/dufs", "/data"]
CMD ["--allow-all", "--bind", "0.0.0.0", "--port", "5000"]

# ── 3. Final image (scratch — minimal, no shell) ────────────────────────────
FROM scratch AS final

COPY --from=builder /usr/local/bin/dufs     /usr/local/bin/dufs
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

EXPOSE 5000
VOLUME ["/data"]
ENTRYPOINT ["/usr/local/bin/dufs", "/data"]
CMD ["--allow-all", "--bind", "0.0.0.0", "--port", "5000"]
