#!/usr/bin/env bash

TF=$(mktemp -t ntfy-XXXXXXXXXXX.txt)

cleanup() {
  rm -f "$TF"
}
trap cleanup EXIT

notify() {
  local exit_code=$1
  local title=$2
  local tags="white_check_mark"
  local header="Success"

  if [ "$exit_code" -ne 0 ]; then
    tags="x"
    header="Failed ($exit_code)"
  fi

  ntfy publish \
    --tags "$tags" \
    --title "$title" \
    --message "$header" \
    --file "$TF" \
    "$TOPIC"
}

if [ "$#" -eq 0 ]; then
  # Pipe mode: read stdin, write to temp file and stdout
  tee "$TF"
  notify 0 "Piped command finished"
elif [ "$1" = "--pid" ] || [ "$1" = "-p" ]; then
  # PID mode
  PID="$2"
  if [ -z "$PID" ]; then
    echo "Usage: ntfy-done --pid <PID>"
    exit 1
  fi
  tail --pid="$PID" -f /dev/null
  ntfy publish \
    --tags "white_check_mark" \
    --title "Process $PID finished" \
    "$TOPIC"
else
  # Command mode
  CMD="$*"
  set +e # Don't exit on command failure
  # Run command, capture stdout/stderr to temp file and stdout
  # We use a subshell to pipe, but we need the exit code.
  # PIPESTATUS tells us the exit code of the first command in the pipe.
  # "$@" 2>&1 | tee "$TF"
  # RET=$?
  # # shellcheck disable=SC2181
  # if [ $? -ne 0 ]; then
  #      # This checks tee's exit code, which is usually 0.
  #      # In bash, PIPESTATUS[0] would work, but writeShellApplication uses bash (usually).
  #      # Let's trust set -o pipefail if we could use it, but strictly:
  #      :
  # fi
  # Better approach for bash:
  # ( set -o pipefail; "$@" 2>&1 | tee "$TF" )
  # But capturing the exit code of the command inside the subshell is hard to propagate cleanly without another file.
  
  # Alternative: run command, redirect to file, then cat file? No, not tee-like (realtime).
  
  # Using pipefail:
  set -o pipefail
  "$@" 2>&1 | tee "$TF"
  RET=$?
  notify "$RET" "Command finished: $CMD"
  exit "$RET"
fi