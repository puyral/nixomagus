{ config, pkgs, ... }: {
  imports = [ ./zsh/zsh.nix ];

  home.shellAliases = {
    "rebuild" = "time sudo nixos-rebuild switch --flake /config#";
    "update" = "nix flake update /config#";
  };
}
