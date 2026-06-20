ARG BASE_IMAGE=debian:bookworm-slim
FROM ${BASE_IMAGE}

ARG GO_VERSION=1.26.4
ARG TARGETOS=linux
ARG TARGETARCH
ARG IMAGE_VARIANT=full

COPY shared.sh /tmp/shared/root.sh
COPY generic/shared.sh /tmp/shared/generic.sh
COPY generic/golang/shared.sh /tmp/shared/golang.sh

RUN set -eux; \
    if command -v apk >/dev/null 2>&1; then \
      export GENERIC_ADDITIONAL_PACKAGES="wget tar"; \
      export GENERIC_ADDITIONAL_FULL_PACKAGES="build-base curl git make openssh-client pkgconf"; \
    else \
      export GENERIC_ADDITIONAL_PACKAGES="wget tar"; \
      export GENERIC_ADDITIONAL_FULL_PACKAGES="curl g++ gcc git libc6-dev make openssh-client pkg-config"; \
    fi; \
    sh /tmp/shared/root.sh; \
    bash /tmp/shared/generic.sh; \
    bash /tmp/shared/golang.sh; \
    if [ -z "${TARGETARCH}" ]; then \
      case "$(uname -m)" in \
        x86_64) TARGETARCH="amd64" ;; \
        aarch64) TARGETARCH="arm64" ;; \
        armv6l) TARGETARCH="arm/v6" ;; \
        armv7l) TARGETARCH="arm/v7" ;; \
        i386|i686) TARGETARCH="386" ;; \
        *) echo "unsupported machine architecture: $(uname -m)" >&2; exit 1 ;; \
      esac; \
    fi; \
    case "${TARGETARCH}" in \
      amd64|arm64|386) GO_ARCH="${TARGETARCH}" ;; \
      arm/v6) GO_ARCH="armv6l" ;; \
      arm/v7) GO_ARCH="armv6l" ;; \
      ppc64le|s390x) GO_ARCH="${TARGETARCH}" ;; \
      *) echo "unsupported target architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    TARBALL="go${GO_VERSION}.${TARGETOS}-${GO_ARCH}.tar.gz"; \
    wget -q "https://go.dev/dl/${TARBALL}"; \
    tar -C /usr/local -xzf "${TARBALL}"; \
    rm -f "${TARBALL}"; \
    rm -rf /tmp/shared

ENV PATH="/usr/local/go/bin:${PATH}"
RUN go version
