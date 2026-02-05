{
  rootDir,
  lib,
  is_nixos,
  home-manager,
  pkgs,
  pkgs-pinned-darktable,
  ...
}:
{
  imports = [ (rootDir + "/registeries.nix") ];
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
    home = lib.mkIf (!is_nixos) {
      packages = [
        home-manager.packages.${pkgs.system}.default
      ];
    };
  };
}
