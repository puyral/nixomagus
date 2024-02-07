
{ config, pkgs, ... }:
{
  imports = [ ./zsh.nix ];

  home.shellAliases = {
    "rebuild" = "time sudo nixos-rebuild switch --flake /config#";
  };
}