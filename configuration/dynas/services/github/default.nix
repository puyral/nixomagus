{ pkgs, pkgs-unstable, config, ... }:
{
  sops.secrets.github-token = {
    sopsFile = ./token.sops-secret.yaml;
  };
  extra.github-runners = {
    enable = true;
    runners = {
      auto-config =
        let
          git-crypt-unlocker = pkgs.callPackage ./git-crypt-unlocker { };
        in
        {
          enable = true;
          # don't why I need this. It should have been fixed in https://github.com/NixOS/nixpkgs/pull/508189
          package = pkgs-unstable.github-runner;
          url = "https://github.com/puyral/nixomagus";
          tokenFile = config.sops.secrets.github-token.path;
          name = "dynas";
          extraPackages = [
            git-crypt-unlocker
            pkgs.git-crypt
          ];
        };
    };
  };
}
