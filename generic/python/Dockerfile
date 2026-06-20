ARG BASE_IMAGE=python:3.13.7-slim-bookworm
FROM ${BASE_IMAGE}

COPY shared.sh /tmp/shared/root.sh
COPY generic/shared.sh /tmp/shared/generic.sh
COPY generic/python/shared.sh /tmp/shared/runtime.sh

RUN set -eux; \
    if command -v apk >/dev/null 2>&1; then \
      apk add --no-cache bash ca-certificates; \
    elif command -v apt-get >/dev/null 2>&1; then \
      apt-get update; \
      apt-get install -y --no-install-recommends bash ca-certificates; \
      rm -rf /var/lib/apt/lists/*; \
    fi; \
    bash /tmp/shared/root.sh; \
    bash /tmp/shared/generic.sh; \
    bash /tmp/shared/runtime.sh; \
    rm -rf /tmp/shared

RUN python --version
