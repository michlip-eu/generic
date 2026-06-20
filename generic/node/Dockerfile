ARG BASE_IMAGE=node:24.6.0-bookworm-slim
FROM ${BASE_IMAGE}

COPY shared.sh /tmp/shared/root.sh
COPY generic/shared.sh /tmp/shared/generic.sh
COPY generic/node/shared.sh /tmp/shared/runtime.sh

RUN set -eux; \
    sh /tmp/shared/root.sh; \
    bash /tmp/shared/generic.sh; \
    bash /tmp/shared/runtime.sh; \
    rm -rf /tmp/shared

RUN node --version
