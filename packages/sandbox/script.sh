#!/bin/bash
set -e

# Configuration from Nix substitution
MICROVM_RUNNER="@microvmRunner@"

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
VM_MOUNT_TAG="host-pwd"
VM_MOUNT_PATH="/mnt/host"

# Prepare MicroVM arguments
RUN_ARGS=("-display" "none")
if [ "$PWD_MOUNT" = true ]; then
  echo "Mounting $HOST_PWD into $VM_MOUNT_PATH..."
  RUN_ARGS+=(
    "-fsdev" "local,id=fs-pwd,path=$HOST_PWD,security_model=none,readonly=false"
    "-device" "virtio-9p-pci,fsdev=fs-pwd,mount_tag=$VM_MOUNT_TAG"
  )
fi

# Generate a modified runner script to inject our arguments
# This bypasses the limitation of microvm-run not supporting CLI arguments.
ARG_STRING=$(printf ' %q' "${RUN_ARGS[@]}")
TEMP_RUN=$(mktemp --suffix=.sh)
VM_LOG=$(mktemp --suffix=.log)

# Inject the arguments into the placeholder
# shellcheck disable=SC2001
sed "s|\${runtime_args:-}|$ARG_STRING|" "$MICROVM_RUNNER/bin/microvm-run" > "$TEMP_RUN"
chmod +x "$TEMP_RUN"

# Cleanup on exit: kill the VM and remove temp files
cleanup() {
  echo "Shutting down sandbox..."
  if [ -n "${VM_PID:-}" ]; then
    kill "$VM_PID" 2>/dev/null || true
    wait "$VM_PID" 2>/dev/null || true
  fi
  rm -f "$VM_LOG" "$TEMP_RUN"
}
trap cleanup EXIT

echo "Starting MicroVM..."
# Run the modified script. Since it uses 'exec', VM_PID will be the QEMU process.
"$TEMP_RUN" > "$VM_LOG" 2>&1 &
VM_PID=$!

# Wait for SSH to be ready on port 2222
MAX_ATTEMPTS=30
ATTEMPT=1
while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
  if ssh -p 2222 \
      -o StrictHostKeyChecking=no \
      -o UserKnownHostsFile=/dev/null \
      -o ConnectTimeout=1 \
      -o ConnectionAttempts=1 \
      -o BatchMode=yes \
      -o LogLevel=QUIET \
      simon@localhost true 2>/dev/null; then
    break
  fi
  
  if ! kill -0 "$VM_PID" 2>/dev/null; then
    echo "MicroVM died unexpectedly. Logs:"
    cat "$VM_LOG"
    exit 1
  fi

  sleep 1
  ATTEMPT=$((ATTEMPT + 1))
done

if [ $ATTEMPT -gt $MAX_ATTEMPTS ]; then
  echo "Timed out waiting for SSH."
  exit 1
fi

# Determine the command to run inside the VM
VM_CMD=""
if [ "$PWD_MOUNT" = true ]; then
  # Mount and cd sequence
  VM_CMD="sudo mkdir -p $VM_MOUNT_PATH && sudo mount -t 9p -o trans=virtio,version=9p2000.L $VM_MOUNT_TAG $VM_MOUNT_PATH && cd $VM_MOUNT_PATH"
fi

if [ ${#EXTRA_ARGS[@]} -gt 0 ]; then
  if [ -n "$VM_CMD" ]; then
    VM_CMD="$VM_CMD && ${EXTRA_ARGS[*]}"
  else
    VM_CMD="${EXTRA_ARGS[*]}"
  fi
else
  if [ -n "$VM_CMD" ]; then
    # Default to interactive shell if no command provided
    VM_CMD="$VM_CMD; exec \$SHELL"
  fi
fi

# SSH into the sandbox
# Using -t for interactive TTY
if [ -n "$VM_CMD" ]; then
  ssh -p 2222 -t \
      -o StrictHostKeyChecking=no \
      -o UserKnownHostsFile=/dev/null \
      simon@localhost "bash -l -c '$VM_CMD'"
else
  ssh -p 2222 -t \
      -o StrictHostKeyChecking=no \
      -o UserKnownHostsFile=/dev/null \
      simon@localhost
fi
