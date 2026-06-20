FROM alpine:latest

ARG GO_VERSION=1.26.4
ARG TARGETOS=linux
ARG TARGETARCH

COPY shared.sh /tmp/shared/root.sh
COPY generic/shared.sh /tmp/shared/generic.sh
COPY generic/golang/shared.sh /tmp/shared/golang.sh

RUN set -eux; \
    apk add --no-cache bash ca-certificates wget tar; \
    bash /tmp/shared/root.sh; \
    bash /tmp/shared/generic.sh; \
    bash /tmp/shared/golang.sh; \
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
