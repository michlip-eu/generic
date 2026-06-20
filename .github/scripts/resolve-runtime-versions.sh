#!/usr/bin/env bash
set -euo pipefail

runtime="${1:?usage: resolve-runtime-versions.sh <runtime>}"
versions_file="${VERSIONS_FILE:-generic/${runtime}/versions.yml}"
update_versions_file="${UPDATE_VERSIONS_FILE:-true}"

config() {
  case "$runtime" in
    node)
      display_name="Node.js"
      git_repo="https://github.com/nodejs/node.git"
      tag_regex='^refs/tags/v[0-9]+\.[0-9]+\.[0-9]+$'
      tag_sed='s#^refs/tags/v##'
      full_base='node:${version}-bookworm-slim'
      alpine_base='node:${version}-alpine'
      ;;
    bun)
      display_name="Bun.js"
      git_repo="https://github.com/oven-sh/bun.git"
      tag_regex='^refs/tags/bun-v[0-9]+\.[0-9]+\.[0-9]+$'
      tag_sed='s#^refs/tags/bun-v##'
      full_base='oven/bun:${version}'
      alpine_base='oven/bun:${version}-alpine'
      ;;
    deno|dyno)
      runtime="deno"
      versions_file="${VERSIONS_FILE:-generic/${runtime}/versions.yml}"
      display_name="Deno"
      git_repo="https://github.com/denoland/deno.git"
      tag_regex='^refs/tags/v[0-9]+\.[0-9]+\.[0-9]+$'
      tag_sed='s#^refs/tags/v##'
      full_base='denoland/deno:debian-${version}'
      alpine_base='denoland/deno:alpine-${version}'
      ;;
    python)
      display_name="Python"
      git_repo="https://github.com/python/cpython.git"
      tag_regex='^refs/tags/v[0-9]+\.[0-9]+\.[0-9]+$'
      tag_sed='s#^refs/tags/v##'
      full_base='python:${version}-slim-bookworm'
      alpine_base='python:${version}-alpine'
      ;;
    java)
      display_name="Java"
      git_repo="https://github.com/openjdk/jdk.git"
      tag_regex='^refs/tags/jdk-[0-9]+\+[0-9]+$'
      tag_sed='s#^refs/tags/jdk-##; s#\+.*$##'
      full_base='eclipse-temurin:${version}-jdk-jammy'
      alpine_base='eclipse-temurin:${version}-jdk-alpine'
      ;;
    rust)
      display_name="Rust"
      git_repo="https://github.com/rust-lang/rust.git"
      tag_regex='^refs/tags/[0-9]+\.[0-9]+\.[0-9]+$'
      tag_sed='s#^refs/tags/##'
      full_base='rust:${version}-bookworm'
      alpine_base='rust:${version}-alpine'
      ;;
    *)
      echo "unknown runtime: $runtime" >&2
      exit 1
      ;;
  esac
}

latest_count() {
  if [[ ! -f "$versions_file" ]]; then
    printf '2\n'
    return
  fi

  awk -F: '
    /^[[:space:]]*latest_count[[:space:]]*:/ {
      gsub(/[[:space:]]/, "", $2)
      print $2
      found = 1
      exit
    }
    END {
      if (!found) {
        print "2"
      }
    }
  ' "$versions_file"
}

pinned_versions() {
  if [[ ! -f "$versions_file" ]]; then
    return
  fi

  awk '
    /^[[:space:]]*older_versions[[:space:]]*:/ {
      in_versions = 1
      next
    }
    in_versions && /^[^[:space:]-]/ {
      exit
    }
    in_versions && /^[[:space:]]*-/ {
      sub(/^[[:space:]]*-[[:space:]]*/, "")
      sub(/[[:space:]]*#.*/, "")
      gsub(/["'\'']/, "")
      if ($0 != "") {
        print $0
      }
    }
  ' "$versions_file"
}

git_versions() {
  local count="$1"

  git ls-remote --tags --refs "$git_repo" 2>/dev/null |
    awk '{ print $2 }' |
    grep -E "$tag_regex" |
    sed -E "$tag_sed" |
    sort -t. -k1,1nr -k2,2nr -k3,3nr |
    awk '!seen[$0]++' |
    head -n "$count"
}

line_for() {
  local version="$1"

  case "$runtime" in
    node|java)
      printf '%s\n' "$version" | cut -d. -f1
      ;;
    *)
      printf '%s\n' "$version" | cut -d. -f1,2
      ;;
  esac
}

render_base() {
  local template="$1"
  local version="$2"
  printf '%s\n' "${template//\$\{version\}/$version}"
}

config
count="${LATEST_COUNT:-$(latest_count)}"

if [[ ! "$count" =~ ^[0-9]+$ ]] || [[ "$count" -lt 1 ]]; then
  echo "latest_count must be a positive integer: $count" >&2
  exit 1
fi

latest_versions="$(git_versions "$count" || true)"
if [[ -z "$latest_versions" ]]; then
  latest_versions="$(pinned_versions | head -n "$count")"
fi

resolved_versions="$(
  {
    printf '%s\n' "$latest_versions"
    pinned_versions
  } |
    awk 'NF && !seen[$0]++'
)"

if [[ -z "$resolved_versions" ]]; then
  echo "no versions resolved for $runtime" >&2
  exit 1
fi

if [[ "$update_versions_file" == "true" ]]; then
  mkdir -p "$(dirname "$versions_file")"
  {
    printf 'latest_count: %s\n\n' "$count"
    printf 'older_versions:\n'
    while IFS= read -r version; do
      [[ -n "$version" ]] || continue
      printf '  - "%s"\n' "$version"
    done <<< "$resolved_versions"
  } > "$versions_file"
fi

{
  printf '%s\n' "$resolved_versions" |
    jq -Rsc --arg runtime "$runtime" --arg display_name "$display_name" '
      split("\n")
      | map(select(length > 0))
      | {
          runtime: $runtime,
          display_name: $display_name,
          versions: .,
          latest_version: .[0]
        }
    '
  while IFS= read -r version; do
    [[ -n "$version" ]] || continue
    jq -n \
      --arg runtime "$runtime" \
      --arg version "$version" \
      --arg line "$(line_for "$version")" \
      --arg full_base "$(render_base "$full_base" "$version")" \
      --arg alpine_base "$(render_base "$alpine_base" "$version")" \
      '{
        runtime: $runtime,
        version: $version,
        line: $line,
        variants: [
          {name: "full", base_image: $full_base, tag_suffix: ""},
          {name: "alpine", base_image: $alpine_base, tag_suffix: "-alpine"}
        ]
      }'
  done <<< "$resolved_versions" | jq -s '{version_matrix: map(. as $row | $row.variants[] | {runtime: $row.runtime, version: $row.version, line: $row.line, variant: .})}'
} | jq -s '.[0] + .[1]'
