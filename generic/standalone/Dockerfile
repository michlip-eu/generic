ARG BASE_IMAGE=debian:bookworm-slim
FROM ${BASE_IMAGE}

ARG IMAGE_VARIANT=full

COPY shared.sh /tmp/shared/root.sh
COPY generic/shared.sh /tmp/shared/generic.sh
COPY generic/standalone/shared.sh /tmp/shared/standalone.sh

RUN if command -v apk >/dev/null 2>&1; then \
    export GENERIC_ADDITIONAL_FULL_PACKAGES="build-base curl git make openssh-client pkgconf"; \
  else \
    export GENERIC_ADDITIONAL_FULL_PACKAGES="curl g++ gcc git libc6-dev make openssh-client pkg-config"; \
  fi \
  && sh /tmp/shared/root.sh \
  && bash /tmp/shared/generic.sh \
  && bash /tmp/shared/standalone.sh \
  && rm -rf /tmp/shared

CMD ["bash"]
