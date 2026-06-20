#!/usr/bin/env bash
set -euo pipefail

readonly DEFAULT_RELEASES_URL="https://golang.org/dl/?mode=json"
readonly DEFAULT_LATEST_COUNT="2"

versions_file="${VERSIONS_FILE:-generic/golang/versions.yml}"
releases_url="${GO_RELEASES_URL:-$DEFAULT_RELEASES_URL}"
update_versions_file="${UPDATE_VERSIONS_FILE:-true}"

normalize_go_version() {
  local version="${1#go}"

  if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "invalid Go version: $1" >&2
    return 1
  fi

  printf '%s\n' "$version"
}

latest_count() {
  if [[ ! -f "$versions_file" ]]; then
    printf '%s\n' "$DEFAULT_LATEST_COUNT"
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
        print "'"$DEFAULT_LATEST_COUNT"'"
      }
    }
  ' "$versions_file"
}

older_versions() {
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

count="${LATEST_GO_COUNT:-$(latest_count)}"

if [[ ! "$count" =~ ^[0-9]+$ ]] || [[ "$count" -lt 1 ]]; then
  echo "latest_count must be a positive integer: $count" >&2
  exit 1
fi

current_versions="$(
  curl -fsSL "$releases_url" |
    jq -r --argjson count "$count" '
      [.[] | select(.stable == true) | .version][0:$count][]
    '
)"

resolved_versions="$(
  {
    printf '%s\n' "$current_versions"
    older_versions
  } |
    while IFS= read -r version; do
      [[ -n "$version" ]] || continue
      normalize_go_version "$version"
    done |
    awk '!seen[$0]++'
)"

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

printf '%s\n' "$resolved_versions" |
  jq -Rsc '
    split("\n")
    | map(select(length > 0))
    | if length == 0 then
        error("no Go versions resolved")
      else
        {
          versions: .,
          latest_version: .[0],
          matrix: map({version: .})
        }
      end
  '
