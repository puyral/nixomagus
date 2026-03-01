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

if [ "$1" = "--topic" ] || [ "$1" = "-t" ]; then
  TOPIC="$2"
  shift 2
fi

if [ -z "$TOPIC" ]; then
  echo "Error: TOPIC not set. Use --topic <topic> or -t <topic>"
  exit 1
fi

if [ "$#" -eq 0 ]; then
  # Pipe mode: read stdin, write to temp file and stdout
  tee "$TF"
  notify 0 "Piped command finished"
elif [ "$1" = "--pid" ] || [ "$1" = "-p" ]; then
  # PID mode
  PID="$2"
  if [ -z "$PID" ]; then
    echo "Usage: ntfy-done --topic <topic> --pid <PID>"
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
  
  # Using pipefail:
  set -o pipefail
  "$@" 2>&1 | tee "$TF"
  RET=$?
  notify "$RET" "Command finished: $CMD"
  exit "$RET"
fi