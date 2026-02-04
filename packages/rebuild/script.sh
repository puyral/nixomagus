#!/bin/bash
set -e

# Define color codes
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BOLD="\033[1m"
RESET="\033[0m"

# Configuration from Nix substitution
CONFIG_DIR="@flakePath@"
DEFAULT_TYPE="@type@" # "nixos" or "home-manager"
USER_NAME="@name@"

# Runtime Variables
TYPE="$DEFAULT_TYPE"
ACTION="switch"
DO_SIGN=true
ONLY_SNAPSHOT=false
TARGET=""
EXTRA_ARGS=()

# Argument Parsing
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            ACTION="build"
            shift
            ;;
        --no-sign)
            DO_SIGN=false
            shift
            ;;
        --snapshot)
            ONLY_SNAPSHOT=true
            shift
            ;;
        --hm)
            TYPE="home-manager"
            shift
            ;;
        --)
            shift
            EXTRA_ARGS+=("$@")
            break
            ;;
        -*)
            echo "Unknown option: $1"
            exit 1
            ;;
        *)
            if [ -z "$TARGET" ]; then
                TARGET="$1"
                TYPE="nixos"
                # If explicitly targeting another host, default to build unless specified otherwise?
                # The user request said: "rebuild ovh-pl would trigger ... build"
                ACTION="build" 
            else
                echo "Unknown argument: $1"
                exit 1
            fi
            shift
            ;;
    esac
done

# --- Snapshot Logic ---
HOST_BRANCH=$(hostname)
NEW_COMMIT=""
MSG_PREFIX="rebuild"
if [ "$ONLY_SNAPSHOT" = true ]; then
    MSG_PREFIX="snapshot"
fi

echo -e "${YELLOW}${BOLD}==> Creating backup on branch $HOST_BRANCH...${RESET}"

if git -C "$CONFIG_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    # Create stash (index + worktree + untracked)
    # We always disable GPG for the stash creation itself to avoid interactive prompt loop there
    STASH_HASH=$(git -C "$CONFIG_DIR" -c commit.gpgsign=false stash create --include-untracked)

    if [ -z "$STASH_HASH" ]; then
        TREE_HASH=$(git -C "$CONFIG_DIR" rev-parse "HEAD^{tree}")
    else
        TREE_HASH=$(git -C "$CONFIG_DIR" show -s --format=%T "$STASH_HASH")
    fi

    PARENT_COMMIT=$(git -C "$CONFIG_DIR" rev-parse --verify "$HOST_BRANCH" 2>/dev/null || true)
    
    if [ -z "$PARENT_COMMIT" ]; then
        PARENT_COMMIT=$(git -C "$CONFIG_DIR" rev-parse --verify "master" 2>/dev/null || true)
        if [ -n "$PARENT_COMMIT" ]; then
            echo -e "${YELLOW}Branch $HOST_BRANCH not found. Seeding from master.${RESET}"
        fi
    fi

    COMMIT_ARGS=("$TREE_HASH")
    if [ -n "$PARENT_COMMIT" ]; then
        COMMIT_ARGS+=("-p" "$PARENT_COMMIT")
    fi

    # Handle Signing
    if [ "$DO_SIGN" = true ]; then
        GPG_FLAG="-S"
    else
        GPG_FLAG="-c commit.gpgsign=false"
    fi

    # Create the commit
    # shellcheck disable=SC2086
    NEW_COMMIT=$(git -C "$CONFIG_DIR" $GPG_FLAG commit-tree "${COMMIT_ARGS[@]}" -m "$MSG_PREFIX $(date)")

    echo -e "${YELLOW}Snapshot created: $NEW_COMMIT${RESET}"
else
    echo -e "${YELLOW}Warning: $CONFIG_DIR is not a git repository. Skipping backup.${RESET}"
fi

# Update ref immediately if it's just a snapshot
if [ "$ONLY_SNAPSHOT" = true ]; then
    if [ -n "$NEW_COMMIT" ]; then
        git -C "$CONFIG_DIR" update-ref "refs/heads/$HOST_BRANCH" "$NEW_COMMIT"
        echo -e "${GREEN}Snapshot saved to $HOST_BRANCH${RESET}"
    fi
    exit 0
fi

# --- Rebuild Logic ---
echo -e "${YELLOW}${BOLD}==> Running rebuild ($TYPE)...${RESET}"

CMD=()

if [ "$TYPE" = "home-manager" ]; then
    CMD=("home-manager" "$ACTION" "--flake" "${CONFIG_DIR}")
elif [ "$TYPE" = "nixos" ]; then
    if [ -n "$TARGET" ]; then
        # Remote build
        CMD=("nixos-rebuild" "--target-host" "${USER_NAME}@${TARGET}" "--use-remote-sudo" "$ACTION" "--flake" "${CONFIG_DIR}#${TARGET}")
    else
        # Local build
        CMD=("sudo" "nixos-rebuild" "$ACTION" "--flake" "${CONFIG_DIR}")
    fi
fi

# Append extra args
CMD+=("${EXTRA_ARGS[@]}")

# Execute
"${CMD[@]}"

# --- Post-Success Logic ---
if [ -n "$NEW_COMMIT" ]; then
    echo -e "${YELLOW}${BOLD}==> Rebuild successful. Updating $HOST_BRANCH...${RESET}"
    git -C "$CONFIG_DIR" update-ref "refs/heads/$HOST_BRANCH" "$NEW_COMMIT"
    echo -e "${GREEN}Backup confirmed: $NEW_COMMIT (branch: $HOST_BRANCH)${RESET}"
fi

echo -e "${GREEN}✅ Success${RESET}"