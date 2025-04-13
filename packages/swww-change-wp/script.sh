#!/usr/bin/env bash
set -euo pipefail
set -x
wallpaperDir=$1
shift

for monitor in $(swww query | grep -Po "^[^:]+"); do
  wallpaper=$(find "$wallpaperDir" -type f | shuf -n 1)
  swww img "$wallpaper" -o "$monitor" "$@"
done