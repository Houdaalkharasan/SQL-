#!/usr/bin/env bash
set -euo pipefail

BRANCH="pr/final-schema-$(date +%Y%m%d%H%M%S)"
echo "Using branch: $BRANCH"

echo "--- git status (porcelain) ---"
git status --porcelain || true

echo "--- current branch ---"
git rev-parse --abbrev-ref HEAD || true

echo "--- remote origin url ---"
git config --get remote.origin.url || true

echo "--- creating branch ---"
git checkout -b "$BRANCH"

echo "--- git add -A ---"
git add -A

# Commit only if there are staged changes
if git diff --cached --quiet; then
  echo "No staged changes to commit."
else
  git commit -m "chore: update schema (auto PR)"
  echo "Committed changes."
fi

echo "--- git push ---"
if git push --set-upstream origin "$BRANCH"; then
  echo "PUSH: ok -> origin/$BRANCH"
else
  echo "PUSH: failed" >&2
  exit 2
fi

# Create PR using gh if available, otherwise print compare URL
if command -v gh >/dev/null 2>&1; then
  echo "GHCLI: found, creating PR..."
  gh pr create --title "Update schema.sql" --body "Auto-generated PR: pushing current workspace changes." --base main --fill && echo "PR: created by gh" || (echo "PR: gh create failed" >&2; exit 3)
else
  echo "GHCLI: not found"
  REMOTE_URL=$(git config --get remote.origin.url || true)
  if [ -z "$REMOTE_URL" ]; then
    echo "No remote.origin.url set; cannot form PR URL" >&2
    exit 4
  fi
  if echo "$REMOTE_URL" | grep -q "git@github.com:"; then
    REPO_PATH=$(echo "$REMOTE_URL" | sed -E 's/git@github.com:(.*)\.git/\1/')
  else
    REPO_PATH=$(echo "$REMOTE_URL" | sed -E 's#https://github.com/(.*)\.git#\1#')
  fi
  echo "Open this URL to create the PR:" 
  echo "https://github.com/$REPO_PATH/compare/main...$BRANCH?expand=1"
fi
