{ config, pkgs, ... }:
{
  imports = [ ./zsh/zsh.nix ];

  home.shellAliases = {
    "rebuild" = "time sudo nixos-rebuild switch --flake '/config'"; # ?submodules=1#'";
    "update" = "nix flake update /config#";
    # "start-camera" = "" + ./scripts/start-camera.sh;
    "uro" = "bash ${./scripts/update-upgrade-optimize.sh}";
  };

  # home.file.".cache/scipts/start-camera".source = ./scripts/start-camera.sh;
}
