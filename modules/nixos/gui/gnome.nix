{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.extra.gui;

in

{
  config = lib.mkIf (cfg.enable && cfg.gnome) {
    services.xserver.enable = true;
    services.desktopManager.gnome.enable = true;
    services.displayManager.gdm = {
      enable = true;
      autoSuspend = false;
    };
    environment.systemPackages = with pkgs.gnomeExtensions; [
      wallpaper-slideshow
      tailscale-status
    ];
  };

}
