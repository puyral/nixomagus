set -e  # Exit on any error

# Define color codes
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BOLD="\033[1m"
RESET="\033[0m"

echo -e "${YELLOW}${BOLD}==> Running: nixos-rebuild switch${RESET}"
sudo nixos-rebuild switch --flake '/config'
echo -e "${GREEN}✅ Success: nixos-rebuild switch completed${RESET}"