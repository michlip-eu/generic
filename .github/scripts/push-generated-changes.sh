#!/usr/bin/env bash
set -euo pipefail

branch="${GITHUB_REF_NAME:-main}"
max_attempts="${PUSH_ATTEMPTS:-5}"

for ((attempt = 1; attempt <= max_attempts; attempt++)); do
  if git push origin "HEAD:${branch}"; then
    exit 0
  fi

  if ((attempt == max_attempts)); then
    break
  fi

  echo "Push raced with another update; rebasing onto origin/${branch} (attempt ${attempt}/${max_attempts})." >&2
  git fetch origin "$branch"
  if ! git rebase "origin/${branch}"; then
    git rebase --abort || true
    echo "Unable to rebase generated changes onto origin/${branch}." >&2
    exit 1
  fi
  sleep $((attempt * 2))
done

echo "Unable to push generated changes after ${max_attempts} attempts." >&2
exit 1
