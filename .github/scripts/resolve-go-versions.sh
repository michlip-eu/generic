#!/usr/bin/env bash
set -euo pipefail

readonly DEFAULT_RELEASES_URL="https://golang.org/dl/?mode=json"
readonly DEFAULT_GIT_TAGS_URL="https://github.com/golang/go.git"

versions_file="${VERSIONS_FILE:-generic/golang/versions.yml}"
releases_url="${GO_RELEASES_URL:-$DEFAULT_RELEASES_URL}"
git_tags_url="${GO_GIT_TAGS_URL:-$DEFAULT_GIT_TAGS_URL}"
update_versions_file="${UPDATE_VERSIONS_FILE:-true}"

normalize_go_version() {
  local version="${1#go}"

  if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "invalid Go version: $1" >&2
    return 1
  fi

  printf '%s\n' "$version"
}

older_versions() {
  if [[ ! -f "$versions_file" ]]; then
    return
  fi

  awk '
    /^[[:space:]]*(older_versions|versions)[[:space:]]*:/ {
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
  git ls-remote --tags --refs "$git_tags_url" 2>/dev/null |
    awk '{ print $2 }' |
    grep -E '^refs/tags/go[0-9]+\.[0-9]+\.[0-9]+$' |
    sed -E 's#^refs/tags/go##' |
    sort -t. -k1,1nr -k2,2nr -k3,3nr |
    awk '!seen[$0]++'
}

current_versions="$(
  curl -fsSL "$releases_url" 2>/dev/null |
    jq -r '
      .[] | select(.stable == true) | .version
    ' || true
)"
tag_versions="$(git_versions || true)"

resolved_versions="$(
  {
    printf '%s\n' "$current_versions"
    printf '%s\n' "$tag_versions"
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
    printf 'versions:\n'
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
