#!/bin/bash
TMPBG=/tmp/screen.png
LOCK=$HOME/lock.png
RES=$(xrandr | grep 'current' | sed -E 's/.*current\s([0-9]+)\sx\s([0-9]+).*/\1x\2/')
 
ffmpeg -f x11grab -video_size $RES -y -i $DISPLAY -filter_complex "gblur=sigma=200:steps=5" -vframes 1 $TMPBG  -loglevel quiet
$HOME/.config/i3/scripts/lock.sh -i "$TMPBG"
rm $TMPBG
