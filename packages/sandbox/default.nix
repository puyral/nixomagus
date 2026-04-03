{
  writeShellApplication,
  microvmRunner,
  openssh,
  netcat-openbsd,
}:
writeShellApplication {
  name = "sandbox";
  runtimeInputs = [
    openssh
    netcat-openbsd
  ];
  text = ''
    echo "Starting sandbox..."
    # Start the microvm in the background.
    ${microvmRunner}/bin/microvm-run >/dev/null 2>&1 &
    VM_PID=$!

    # Cleanup on exit: kill the VM
    trap 'kill "$VM_PID" 2>/dev/null || true' EXIT

    # Wait for SSH to be ready on port 2222
    # Note: QEMU user networking opens the port immediately on the host.
    # We must retry the SSH connection itself until the guest's SSH server responds.
    
    MAX_ATTEMPTS=30
    ATTEMPT=1
    while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
      # Attempt a quick SSH probe
      # -o ConnectTimeout=1: Don't hang long on a single attempt
      # -o BatchMode=yes: This is the key! It makes SSH fail immediately if 
      #                  pubkey is not ready yet, instead of asking for a password.
      # 'true' as a command just checks if we can execute something and exit
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
        echo "MicroVM died unexpectedly"
        exit 1
      fi

      sleep 1
      ATTEMPT=$((ATTEMPT + 1))
      
      if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
        echo "Timed out waiting for SSH to become ready."
        exit 1
      fi
    done

    # Now that we know SSH is responding AND accepting our keys, enter interactive session
    ssh -p 2222 -t \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        simon@localhost "$@"
  '';
}
