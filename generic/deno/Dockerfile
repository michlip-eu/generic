ARG BASE_IMAGE=denoland/deno:debian-2.4.5
FROM ${BASE_IMAGE}

COPY shared.sh /tmp/shared/root.sh
COPY generic/shared.sh /tmp/shared/generic.sh
COPY generic/deno/shared.sh /tmp/shared/runtime.sh

RUN set -eux; \
    sh /tmp/shared/root.sh; \
    bash /tmp/shared/generic.sh; \
    bash /tmp/shared/runtime.sh; \
    rm -rf /tmp/shared

RUN deno --version
