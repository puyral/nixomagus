{
  nixpkgs-stable,
  system,
  lib,
  config,
  ...
}:
with lib;
let
  # https://github.com/NixOS/nixpkgs/issues/341683
  pkgs-stable' = import nixpkgs-stable {
    inherit system;
    config = {
      permittedInsecurePackages = [ "electron-39.8.10" ];
    };
  };
  cfg = config.extra.logseq;

in
{
  options.extra.logseq.enable = mkEnableOption "Logseq";
  config.home = mkIf cfg.enable {
    packages = [ pkgs-stable'.logseq ];
  };
}
