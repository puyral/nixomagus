#!/usr/bin/env bash
set -euo pipefail
set -x
wallpaperDir=$1
shift

for monitor in $(swww query | awk '{print $2}' | sed s/://); do
  wallpaper=$(find "$wallpaperDir" -type f | shuf -n 1)
  swww img "$wallpaper" -o "$monitor" "$@"
done