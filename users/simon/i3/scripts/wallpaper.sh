#!/usr/bin/env -S nix shell nixpkgs#bash nixpkgs#feh --command bash
# xrandr --output HDMI-0 --primary --mode 3840x2160 --pos 1280x0 --rotate normal --output DP-0 --mode 1280x1024 --pos 0x0 --rotate normal --output DP-1 --off --output eDP-1-1 --mode 1920x1080 --pos 5120x903 --rotate normal --output DP-1-1 --off --output HDMI-1-1 --off
# xrandr --output eDP-1-1 --mode 1920x1080 --rotate normal --output DP-1-1 --off --output HDMI-1-1 --off

while true
do
    feh --recursive --randomize --bg-fill /Volumes/Zeno/media/photos/wallpaper;
    sleep $1
done
