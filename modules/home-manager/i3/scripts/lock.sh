#!/bin/sh

revert() {
  ~/.config/i3/scripts/set-dpms.sh
}

trap revert HUP INT TERM
xset +dpms dpms 5 5 5
i3lock -n -k -e --time-color=FFFFFFFF --date-color=FFFFFFFF --indicator --ring-width=3.0 --inside-color=131314FF --line-uses-inside --screen=1 --pass-media-keys --pass-volume-keys "$@"
revert

