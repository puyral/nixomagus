{ config, pkgs, ... }: {
  imports = [ ./zsh/zsh.nix ];

  home.shellAliases = {
    "rebuild" = "time sudo nixos-rebuild switch --flake '/config?submodules=1#'";
    "update" = "nix flake update /config#";
  };
}
