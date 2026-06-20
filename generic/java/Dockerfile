ARG BASE_IMAGE=eclipse-temurin:24-jdk-jammy
FROM ${BASE_IMAGE}

COPY shared.sh /tmp/shared/root.sh
COPY generic/shared.sh /tmp/shared/generic.sh
COPY generic/java/shared.sh /tmp/shared/runtime.sh

RUN set -eux; \
    sh /tmp/shared/root.sh; \
    bash /tmp/shared/generic.sh; \
    bash /tmp/shared/runtime.sh; \
    rm -rf /tmp/shared

RUN java -version
