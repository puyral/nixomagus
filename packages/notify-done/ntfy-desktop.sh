#!/usr/bin/env bash


# Forward ntfy notifications to desktop notifications
# Reads JSON from stdin, sends to notify-send

while read -r line; do
  title=$(echo "$line" | jq -r '.title // ""')
  message=$(echo "$line" | jq -r '.message // ""')
  
  if [ -n "$message" ] && [ "$message" != "null" ]; then
    notify-send -i dialog-information -a ntfy -c "$title" -u normal "$message"
  fi
done