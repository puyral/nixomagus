# Get the current fullscreen state of the focused window
current_state=$(hyprctl -j getoption fullscreen:"$1" | jq -r '.int')

# Toggle the fullscreen state
if [ "$current_state" -eq "-1" ]; then
    hyprctl dispatch fullscreenstate 0 2
else
    hyprctl dispatch fullscreenstate -1 -1
fi