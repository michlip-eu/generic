#!/usr/bin/env bash
set -euo pipefail

branch="${GITHUB_REF_NAME:-main}"
retry_delay="${PUSH_RETRY_DELAY_SECONDS:-5}"
attempt=0

while true; do
  attempt=$((attempt + 1))
  if git push origin "HEAD:${branch}"; then
    exit 0
  fi

  echo "Push failed; fetching and rebasing onto origin/${branch} (attempt ${attempt})." >&2
  until git fetch origin "$branch"; do
    echo "Fetch failed; retrying in ${retry_delay} seconds." >&2
    sleep "$retry_delay"
  done

  if ! git rebase -X theirs "origin/${branch}"; then
    git rebase --abort || true
    echo "Rebase failed; retrying in ${retry_delay} seconds." >&2
  fi
  sleep "$retry_delay"
done
