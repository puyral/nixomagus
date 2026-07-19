{ pkgs, ... }:
{
  virtualisation.waydroid = {
    enable = true;
    package = pkgs.waydroid-nftables;
  };
  environment.systemPackages = [ pkgs.wl-clipboard ];
}
