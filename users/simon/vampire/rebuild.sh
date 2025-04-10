set -e  # Exit on any error

# Define color codes
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BOLD="\033[1m"
RESET="\033[0m"

echo -e "${YELLOW}${BOLD}==> Running: home-manager switch${RESET}"
nix run home-manager -- switch --flake '/home/simon/.config/home-manager'
echo -e "${GREEN}✅ Success: home-manager switch completed${RESET}"