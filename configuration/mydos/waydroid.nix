{ pkgs, ... }:
{
  virtualisation.waydroid.enable = true;
  environment.systemPackages = [ pkgs.wl-clipboard ];
}
