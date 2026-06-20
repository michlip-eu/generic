#!/usr/bin/env bash
set -euo pipefail

readonly DEFAULT_RELEASES_URL="https://golang.org/dl/?mode=json"
readonly DEFAULT_LATEST_COUNT="2"

versions_file="${VERSIONS_FILE:-generic/golang/versions.yml}"
releases_url="${GO_RELEASES_URL:-$DEFAULT_RELEASES_URL}"

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

{
  curl -fsSL "$releases_url" |
    jq -r --argjson count "$count" '
      [.[] | select(.stable == true) | .version][0:$count][]
    '
  older_versions
} |
  while IFS= read -r version; do
    normalize_go_version "$version"
  done |
  awk '!seen[$0]++' |
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
