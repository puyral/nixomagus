{
  pkgs,
  pkgs-unstable,
  config,
  ...
}:
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
  # see https://github.com/NixOS/nixpkgs/issues/515284
  nixpkgs.config.permittedInsecurePackages = [
    "nodejs-20.20.2"
  ];
}
