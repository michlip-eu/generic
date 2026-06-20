ARG BASE_IMAGE=rust:1.89.0-bookworm
FROM ${BASE_IMAGE}

COPY shared.sh /tmp/shared/root.sh
COPY generic/shared.sh /tmp/shared/generic.sh
COPY generic/rust/shared.sh /tmp/shared/runtime.sh

RUN set -eux; \
    sh /tmp/shared/root.sh; \
    bash /tmp/shared/generic.sh; \
    bash /tmp/shared/runtime.sh; \
    rm -rf /tmp/shared

RUN rustc --version
