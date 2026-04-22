{
  rootDir,
  lib,
  is_nixos,
  home-manager,
  pkgs,
  nix-index-database,
  ...
}:
{
  imports = [
    nix-index-database.homeModules.default

    (rootDir + "/registeries.nix")
  ];
  options.vars = lib.mkOption {
    type = lib.types.attrs;
    default = { };
  };
  config = {
    nixpkgs = lib.mkIf (!is_nixos) {
      config = {
        allowUnfree = _: true;
      };
    };
    home = {
      packages = [
        home-manager.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
}
