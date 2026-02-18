{ lib, ... }:
{
  imports = [
    ../commun
    ./zsh
    ./wallpaper
    ./systemd-services
    ./starship
    ./ssh
    ./shell
    ./logseq
    ./i3
    ./hyprland
    ./firefox
    ./alacritty
    ./applications
    ./btop
    ./git-config-fetcher
    ./darktable
    ./xkb
    ./tmux
    ./yazi
    ./lazygit
    ./sway
    ./vscode
    ./keyring
    ./git
    ./wandarr
    ./ntfy
    ./sops
    ./opencode
    ./emacs
  ];

  options.extra = {
    nix.configDir =
      with lib;
      mkOption {
        type = types.path;
        default = "/config";
      };
  };
}
