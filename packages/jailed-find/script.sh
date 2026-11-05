#!/usr/bin/env bash

REAL_FIND="@find@"
TIMEOUT_DURATION="@timeout@"

eecho() {
  echo "$@" >&2
}

COMMON_ERROR="Hint: use tools better suited to your specific needs in order to get a narrowed path. If none exists and you are sure of what you are doing, 'fd' bypasses this guard"


# Quick check: block bare '/' or '/nix/store', but allow '/nix/store/<drv>'
for arg in "$@"; do
    # Stop checking paths once we hit find flags/predicates
    [[ "$arg" == -* || "$arg" == "(" || "$arg" == "!" ]] && break
    
    resolved=$(realpath -m "$arg" 2>/dev/null || echo "$arg")
    if [[ "$resolved" == "/" || "$resolved" == "/nix" || "$resolved" == "/nix/store" ]]; then
        eecho "[ERROR] Refusing to run 'find' on the entirety of '$resolved' (it will hang). " \
          "Hint: If you want to search a Nix derivation, pass the specific '/nix/store/<hash>-<name>' path instead. " \
          "$COMMON_ERROR"
        exit 1
    fi
done

timeout --kill-after=5s "$TIMEOUT_DURATION" "$REAL_FIND" "$@"
exit_code=$?

if [ $exit_code -eq 124 ] || [ $exit_code -eq 137 ]; then
    eecho -e "\n[ERROR] 'find' timed out after $TIMEOUT_DURATION. " \
      "$COMMON_ERROR"
    exit $exit_code
fi

exit $exit_code