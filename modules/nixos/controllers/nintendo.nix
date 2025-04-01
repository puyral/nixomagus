{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.extra.controllers.nintendo;
  steamcontroller-udev-rules = pkgs.callPackage ./steamcontroller-udev-rules.nix { };
in
{
  config = lib.mkIf cfg.enable {
    services.udev.packages = [
      steamcontroller-udev-rules
    ];
  };
}
