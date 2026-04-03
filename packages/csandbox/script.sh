#!/bin/bash
set -e

# Configuration from Nix substitution
CSANDBOX_SYSTEM="@csandboxSystem@"

# State
PWD_MOUNT=true
EXTRA_ARGS=()

# Argument parsing
while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-pwd)
      PWD_MOUNT=false
      shift
      ;;
    *)
      # Any other args are passed to the shell inside the VM
      EXTRA_ARGS+=("$1")
      shift
      ;;
  esac
done

# Prepare host-side variables
HOST_PWD=$(pwd)
VM_MOUNT_PATH="/mnt/host"

# Prepare nspawn arguments
NSPAWN_ARGS=(
  "--quiet"
  "--as-pid2"
  "--bind-ro=/nix/store"
  "--bind-ro=/nix/var/nix/db"
  "--bind-ro=/nix/var/nix/daemon-socket"
  "--bind-ro=/etc/resolv.conf"
)

if [ "$PWD_MOUNT" = true ]; then
  echo "Mounting $HOST_PWD into $VM_MOUNT_PATH..."
  NSPAWN_ARGS+=("--bind=$HOST_PWD:$VM_MOUNT_PATH")
fi

# Determine the command to run inside the container
# Note: we use /run/current-system/sw/bin/bash -l as the entry point
# We need to ensure that the environment is set up.

INNER_CMD=""
if [ "$PWD_MOUNT" = true ]; then
  INNER_CMD="cd $VM_MOUNT_PATH"
fi

if [ ${#EXTRA_ARGS[@]} -gt 0 ]; then
  ESCAPED_EXTRA_ARGS=$(printf " %q" "${EXTRA_ARGS[@]}")
  if [ -n "$INNER_CMD" ]; then
    INNER_CMD="$INNER_CMD && $ESCAPED_EXTRA_ARGS"
  else
    INNER_CMD="$ESCAPED_EXTRA_ARGS"
  fi
else
  if [ -n "$INNER_CMD" ]; then
    INNER_CMD="$INNER_CMD; exec /run/current-system/sw/bin/bash -l"
  else
    INNER_CMD="exec /run/current-system/sw/bin/bash -l"
  fi
fi

# Run the container
# We use sudo because systemd-nspawn needs it.
# We set the environment variable to ensure Nix commands use the host daemon.
# We use -u simon to run as the correct user.
# --volatile=yes makes the root filesystem writable via tmpfs (for /etc, /var, etc.)

echo "Starting container-based sandbox..."
# shellcheck disable=SC2024
sudo NIX_REMOTE=daemon \
  systemd-nspawn "${NSPAWN_ARGS[@]}" \
  -D "$CSANDBOX_SYSTEM" \
  --user=simon \
  /run/current-system/sw/bin/bash -l -c "$INNER_CMD"
