#!/usr/bin/env bash
set -euo pipefail

# obviously vibe coded

usage() {
  echo "Usage: $(basename "$0") <target-org-or-user>"
  exit 1
}

# 1. Check arguments
if [ "$#" -ne 1 ] || [ -z "$1" ]; then
  usage
fi
TARGET_ORG="$1"

# 2. Check required dependencies
for cmd in git tea; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Error: Required command '$cmd' is not installed or not in PATH." >&2
    exit 1
  fi
done

# 3. Verify current directory is inside a Git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: Not inside a Git repository." >&2
  exit 1
fi

# 4. Resolve the remote URL (prefer 'origin', fallback to first remote)
REMOTE_NAME="origin"
REMOTE_URL=$(git remote get-url "$REMOTE_NAME" 2>/dev/null || true)

if [ -z "$REMOTE_URL" ]; then
  FIRST_REMOTE=$(git remote | head -n 1)
  if [ -z "$FIRST_REMOTE" ]; then
    echo "Error: No Git remotes found in this repository." >&2
    exit 1
  fi
  REMOTE_NAME="$FIRST_REMOTE"
  REMOTE_URL=$(git remote get-url "$REMOTE_NAME")
fi

# 5. Extract owner and repository name
# Handles:
#   ssh://git@forge.domain.com:2222/alice/repo.git
#   git@forge.domain.com:alice/repo.git
#   https://forge.domain.com/alice/repo.git
CLEAN_PATH=$(echo "$REMOTE_URL" | sed -E 's/.*[:\/]([^/]+\/[^/]+)(\.git)?$/\1/' | sed 's/\.git$//')

CURRENT_OWNER="${CLEAN_PATH%/*}"
REPO_NAME="${CLEAN_PATH#*/}"

if [ -z "$CURRENT_OWNER" ] || [ -z "$REPO_NAME" ]; then
  echo "Error: Could not extract owner and repo name from remote URL: $REMOTE_URL" >&2
  exit 1
fi

echo "Repository detected : ${CURRENT_OWNER}/${REPO_NAME}"
echo "Target recipient    : ${TARGET_ORG}"
echo "Remote being updated: ${REMOTE_NAME}"

# 6. Execute transfer via tea api
echo "Initiating transfer via 'tea api'..."
if ! tea api -X POST "repos/${CURRENT_OWNER}/${REPO_NAME}/transfer" \
    -H "Content-Type: application/json" \
    -d "{\"new_owner\": \"${TARGET_ORG}\"}"; then
  echo "Error: Transfer failed. Verify permissions for '$TARGET_ORG' and 'tea' authentication." >&2
  exit 1
fi

echo "Transfer successful!"

# 7. Update the local Git remote to avoid relying on redirects
NEW_REMOTE_URL=$(echo "$REMOTE_URL" | sed "s|/${CURRENT_OWNER}/${REPO_NAME}|/${TARGET_ORG}/${REPO_NAME}|; s|:${CURRENT_OWNER}/${REPO_NAME}|:${TARGET_ORG}/${REPO_NAME}|")
git remote set-url "$REMOTE_NAME" "$NEW_REMOTE_URL"

echo "Updated local remote '${REMOTE_NAME}' -> ${NEW_REMOTE_URL}"