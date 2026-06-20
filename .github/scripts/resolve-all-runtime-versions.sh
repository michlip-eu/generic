#!/usr/bin/env bash
set -euo pipefail

runtimes="${RUNTIMES:-node bun deno python java rust}"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

for runtime in $runtimes; do
  .github/scripts/resolve-runtime-versions.sh "$runtime" > "${tmp_dir}/${runtime}.json"
done

jq -s '
  {
    runtimes: map({runtime, display_name, versions, latest_version}),
    matrix: map(.version_matrix) | add
  }
' "${tmp_dir}"/*.json
