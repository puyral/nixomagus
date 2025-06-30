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
  config = lib.mkIf (cfg.enable && cfg.hyprland) {
    # enable hyprland
    programs.hyprland = {
      enable = true;
      package = pkgs.hyprland;
      withUWSM = true;
    };

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      config = {
        common.default = [ "gtk" ];
        hyprland.default = [
          "gtk"
          "hyprland"
        ];
      };
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-wlr
        pkgs.xdg-desktop-portal-hyprland
      ];
    };
  };
}
