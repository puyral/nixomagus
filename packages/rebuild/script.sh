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

show_help() {
    echo "Usage: rebuild [OPTIONS] [TARGET]"
    echo ""
    echo "Options:"
    echo "  --dry-run      Perform a dry run (build instead of switch)."
    echo "  --no-sign      Disable GPG signing for the backup commit."
    echo "  --snapshot     Only create a git snapshot, do not rebuild."
    echo "  --hm           Force Home Manager mode."
    echo "  -h, --help     Show this help message."
    echo ""
    echo "Arguments:"
    echo "  TARGET         Hostname for remote build (implies NixOS build)."
    echo ""
    echo "Examples:"
    echo "  rebuild --dry-run"
    echo "  rebuild ovh-pl"
    echo "  rebuild --snapshot"
}

# Argument Parsing
while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--dry-run)
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
        -h|--help)
            show_help
            exit 0
            ;;
        --)
            shift
            EXTRA_ARGS+=("$@")
            break
            ;;
        -*)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
        *)
            if [ -z "$TARGET" ]; then
                TARGET="$1"
                TYPE="nixos"
                # If explicitly targeting another host, default to build unless specified otherwise?
                # The user request said: "rebuild ovh-pl would trigger ... build"
                # ACTION="build" 
            else
                echo "Unknown argument: $1"
                exit 1
            fi
            shift
            ;;
    esac
done

# --- Snapshot Logic ---
if [ -n "$TARGET" ]; then
    HOST_BRANCH="$TARGET"
else
    HOST_BRANCH=$(hostname)
fi
NEW_COMMIT=""
MSG_PREFIX="rebuild"
if [ "$ONLY_SNAPSHOT" = true ]; then
    MSG_PREFIX="snapshot"
fi

echo -e "${YELLOW}${BOLD}==> Creating backup on branch $HOST_BRANCH...${RESET}"

if git -C "$CONFIG_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    # Create a snapshot of the current working tree, including untracked files.
    # This is done via a temporary index to ensure git filters (like git-crypt) are applied.
    TMP_INDEX=$(mktemp)
    TMP_HASH_FILE=$(mktemp)
    # Ensure the temporary files are cleaned up on exit
    trap 'rm -f "$TMP_INDEX" "$TMP_HASH_FILE"' EXIT HUP INT QUIT PIPE TERM

    # All git operations affecting the index are done in a subshell.
    # stderr is inherited, so any errors from git or git-crypt will be visible.
    # The final tree hash is written to a temporary file.
    (
        export GIT_INDEX_FILE="$TMP_INDEX"
        # Seed the index with the current HEAD, or an empty tree if it's a new repo
        if ! git -C "$CONFIG_DIR" read-tree HEAD; then
            git -C "$CONFIG_DIR" read-tree "$(git -C "$CONFIG_DIR" hash-object -t tree /dev/null)"
        fi
        # Add all changes from the working tree, which applies the git-crypt filter
        git -C "$CONFIG_DIR" add -A
        # Write the tree object from our temporary index to the hash file
        git -C "$CONFIG_DIR" write-tree > "$TMP_HASH_FILE"
    )

    TREE_HASH=$(cat "$TMP_HASH_FILE")

    # Clean up the trap and the files immediately
    rm -f "$TMP_INDEX" "$TMP_HASH_FILE"
    trap - EXIT HUP INT QUIT PIPE TERM

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
    GIT_FLAGS=""
    COMMIT_FLAGS=""
    
    if [ "$DO_SIGN" = true ]; then
        # -S belongs to commit-tree, not the git wrapper
        COMMIT_FLAGS="-S"
    else
        # -c belongs to the git wrapper
        GIT_FLAGS="-c commit.gpgsign=false"
    fi

    # Create the commit
    # shellcheck disable=SC2086
    NEW_COMMIT=$(git -C "$CONFIG_DIR" $GIT_FLAGS commit-tree "${COMMIT_ARGS[@]}" $COMMIT_FLAGS -m "$MSG_PREFIX $(date)")

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
        CMD=("nixos-rebuild" "--target-host" "${USER_NAME}@${TARGET}" "--sudo" "$ACTION" "--ask-sudo-password" "--flake" "${CONFIG_DIR}#${TARGET}")
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