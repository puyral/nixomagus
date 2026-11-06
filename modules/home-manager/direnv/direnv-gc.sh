#!/usr/bin/env bash

LAYOUTS_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/direnv/layouts"
OLDER_THAN="@olderThan@d"

if [ ! -d "$LAYOUTS_DIR" ]; then
  exit 0
fi

# 1. Remove any stale *.rc caches older than the threshold
fd --exact-depth 2 --type f --extension rc --changed-before "$OLDER_THAN" . "$LAYOUTS_DIR" -X rm -f

# 2. Remove any layout directories that no longer contain any *.rc file
for dir in "$LAYOUTS_DIR"/*/; do
  [ -d "$dir" ] || continue
  if ! fd --exact-depth 1 --type f --extension rc --quiet . "$dir"; then
    rm -rf "$dir"
  fi
done
