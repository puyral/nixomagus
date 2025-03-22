# Check if CONFIG_LOCATION is set
if [ -z "$CONFIG_LOCATION" ]; then
  echo "Error: CONFIG_LOCATION environment variable is not set."
  # return 1
fi

# Check if CONFIG_LOCATION points to a valid Git repository
if [ ! -d "$CONFIG_LOCATION/.git" ]; then
  echo "Error: Directory at CONFIG_LOCATION ($CONFIG_LOCATION) is not a Git repository."
  # return 1
fi

# Check for uncommitted changes
if [ -n "$(git -C "$CONFIG_LOCATION" status --porcelain)" ]; then
  echo "THERE ARE UNCOMMITED CHANGES IN THE LOCAL NIX CONFIGURATION! (see $CONFIG_LOCATION)"
# else
#   echo "No uncommitted changes in $CONFIG_LOCATION."
fi

# FETCH=$(git -C "$CONFIG_LOCATION" fetch) 3 done in a systemd service now
# Check if the branch is ahead, behind, or diverged from the remote
REMOTE_STATUS=$(git -C "$CONFIG_LOCATION" status -sb | grep -E '\[.*\]')
if [[ $REMOTE_STATUS =~ ahead ]]; then
  echo "THE LOCAL NIX CONFIGURATION IS AHEAD OF REMOTE! (see $CONFIG_LOCATION)"
fi

if [[ $REMOTE_STATUS =~ behind ]]; then
  echo "The local nix configuration is behind the remote. (see $CONFIG_LOCATION)"
fi

if [[ $REMOTE_STATUS =~ diverged ]]; then
  echo "THE LOCAL NIX CONFIGURATION HAS DIVERGED FROM REMOTE! (see $CONFIG_LOCATION)"
fi

# If neither ahead nor behind is mentioned
# if [ -z "$REMOTE_STATUS" ]; then
#   echo "Your branch in $CONFIG_LOCATION is up to date with the remote."
# fi