#!/usr/bin/env bash
set -euo pipefail

# Forward ntfy notifications to desktop notifications
# Reads JSON from stdin, sends to notify-send

ntfy sub "$TOPIC" | while IFS= read -r line; do
  title=$(echo "$line" | jq -r '.title // ""')
  message=$(echo "$line" | jq -r '.message // ""')
  
  if [ -n "$message" ] && [ "$message" != "null" ]; then
    notify-send -i dialog-information -a ntfy -u normal "$title" "$message"
  fi
done