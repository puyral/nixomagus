#!/bin/bash
set -e  # Exit on any error

# Define color codes
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BOLD="\033[1m"
RESET="\033[0m"

# Git Backup Logic
CONFIG_DIR="@flakePath@"
HOST_BRANCH=$(hostname)
NEW_COMMIT=""

echo -e "${YELLOW}${BOLD}==> Creating backup on branch $HOST_BRANCH...${RESET}"

# Ensure we are identifying the repo correctly
if git -C "$CONFIG_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    # 1. Create a stash commit object (index + worktree + untracked) without modifying working dir
    # Disable GPG signing to avoid password prompt
    STASH_HASH=$(git -C "$CONFIG_DIR" -c commit.gpgsign=false stash create --include-untracked)
    
    # If no changes (clean worktree), use HEAD tree
    if [ -z "$STASH_HASH" ]; then
        TREE_HASH=$(git -C "$CONFIG_DIR" rev-parse "HEAD^{tree}")
    else
        # Extract the tree hash from the stash commit
        TREE_HASH=$(git -C "$CONFIG_DIR" show -s --format=%T "$STASH_HASH")
    fi

    # 2. Get the current tip of the host branch (parent for the new commit)
    PARENT_COMMIT=$(git -C "$CONFIG_DIR" rev-parse --verify "$HOST_BRANCH" 2>/dev/null || true)
    
    # If the host branch doesn't exist, try to use master as a base
    if [ -z "$PARENT_COMMIT" ]; then
        PARENT_COMMIT=$(git -C "$CONFIG_DIR" rev-parse --verify "master" 2>/dev/null || true)
        if [ -n "$PARENT_COMMIT" ]; then
            echo -e "${YELLOW}Branch $HOST_BRANCH not found. Seeding from master.${RESET}"
        fi
    fi

    # Build arguments array for commit-tree
    COMMIT_ARGS=("$TREE_HASH")
    if [ -n "$PARENT_COMMIT" ]; then
        COMMIT_ARGS+=("-p" "$PARENT_COMMIT")
    fi

    # 3. Create the new commit object (snapshot)
    # Disable GPG signing
    # We store the commit hash but DO NOT update the ref yet
    NEW_COMMIT=$(git -C "$CONFIG_DIR" -c commit.gpgsign=false commit-tree "${COMMIT_ARGS[@]}" -m "rebuild $(date)")

    echo -e "${YELLOW}Snapshot created: $NEW_COMMIT (pending success)${RESET}"
else
    echo -e "${YELLOW}Warning: $CONFIG_DIR is not a git repository. Skipping backup.${RESET}"
fi

echo -e "${YELLOW}${BOLD}==> Running rebuild...${RESET}"
@rebuildCmd@

# Only update the branch reference if the rebuild command succeeded
if [ -n "$NEW_COMMIT" ]; then
    echo -e "${YELLOW}${BOLD}==> Rebuild successful. Updating $HOST_BRANCH...${RESET}"
    git -C "$CONFIG_DIR" update-ref "refs/heads/$HOST_BRANCH" "$NEW_COMMIT"
    echo -e "${GREEN}Backup confirmed: $NEW_COMMIT (branch: $HOST_BRANCH)${RESET}"
fi

echo -e "${GREEN}✅ Success: Rebuild completed${RESET}"
