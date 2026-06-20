#!/bin/sh
# this is setup file for all images

set -eu

install_packages() {
  base_packages="bash ca-certificates ${GENERIC_ADDITIONAL_PACKAGES:-}"

  if command -v apk >/dev/null 2>&1; then
    apk add --no-cache ${base_packages}
    if [ "${IMAGE_VARIANT:-}" = "full" ] && [ -n "${GENERIC_ADDITIONAL_FULL_PACKAGES:-}" ]; then
      apk add --no-cache ${GENERIC_ADDITIONAL_FULL_PACKAGES}
    fi
  elif command -v apt-get >/dev/null 2>&1; then
    apt-get update
    apt-get install -y --no-install-recommends ${base_packages}
    if [ "${IMAGE_VARIANT:-}" = "full" ] && [ -n "${GENERIC_ADDITIONAL_FULL_PACKAGES:-}" ]; then
      apt-get install -y --no-install-recommends ${GENERIC_ADDITIONAL_FULL_PACKAGES}
    fi
    rm -rf /var/lib/apt/lists/*
  else
    echo "unsupported base image package manager" >&2
    exit 1
  fi
}

install_packages
