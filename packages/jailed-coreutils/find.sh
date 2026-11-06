#!/usr/bin/env bash

REAL_FIND="@find@"
TIMEOUT_DURATION="@timeout@"
HINTS_FILE="@hints@"

print_error() {
  echo "[ERROR] $1 Use 'fd'/'rg' or narrow scope (full hints: $HINTS_FILE)." >&2
  cat "$HINTS_FILE" >&2
}

# Collect path operands (everything before the first -, (, or !)
paths=()
for arg in "$@"; do
  [[ "$arg" == -* || "$arg" == "(" || "$arg" == "!" ]] && break
  paths+=("$arg")
done

# Default to current directory if no paths were explicitly passed
if ((${#paths[@]} == 0)); then
  paths=(".")
fi

# Block bare '/', '/nix', or '/nix/store', but allow '/nix/store/<drv>'
for p in "${paths[@]}"; do
  resolved=$(realpath -m "$p" 2>/dev/null || echo "$p")
  if [[ "$resolved" == "/" || "$resolved" == "/nix" || "$resolved" == "/nix/store" ]]; then
    print_error "Refusing to run 'find' on the entirety of '$resolved' (it will hang)."
    exit 1
  fi
done

exit_code=0
timeout --kill-after=5s "$TIMEOUT_DURATION" "$REAL_FIND" "$@" || exit_code=$?

if [ "$exit_code" -eq 124 ] || [ "$exit_code" -eq 137 ]; then
  echo "" >&2
  print_error "'find' timed out after $TIMEOUT_DURATION."
  exit "$exit_code"
fi

exit "$exit_code"
