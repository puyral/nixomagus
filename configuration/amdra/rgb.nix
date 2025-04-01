{ pkgs, ... }:
let
  openrgb = pkgs.openrgb-with-all-plugins;
in
{
  services.hardware.openrgb = {
    enable = true;
    package = openrgb;
  };
  environment.systemPackages = [
    openrgb
  ];
}
