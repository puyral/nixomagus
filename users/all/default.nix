{
  rootDir,
  lib,
  is_nixos,
  home-manager,
  pkgs,
  ...
}:
{
  imports = [ (rootDir + "/registeries.nix") ];
  nixpkgs.config = {
    allowUnfree = _: true;
  };
  home = lib.mkIf (!is_nixos) {
    packages = [
      home-manager.packages.${pkgs.system}.default
    ];
  };
}
