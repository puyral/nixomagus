{ lib, ... }:
{
  imports = [
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
    ./git-config-fetcher
    ./generate-jpgs
    ./xkb
    ./tmux
    ./yazi
    ./lazygit
    ./sway
    ./vscode
    ./keyring
    ./git
    ./wandarr
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
