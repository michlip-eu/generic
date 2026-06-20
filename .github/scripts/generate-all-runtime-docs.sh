#!/usr/bin/env bash
set -euo pipefail

runtimes="${RUNTIMES:-node bun deno python java rust}"

for runtime in $runtimes; do
  IMAGE_NAME="${IMAGE_PREFIX:-ghcr.io/michlip-eu/generic}/${runtime}" \
    .github/scripts/generate-runtime-docs.sh "$runtime"
done
