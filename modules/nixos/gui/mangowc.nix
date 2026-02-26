{
  config,
  lib,
  mangowc,
  pkgs,
  ...
}:

let
  cfg = config.extra.gui;
in
{
  imports = [ mangowc.nixosModules.mango ];

  config = lib.mkIf (cfg.enable && cfg.mangowc) {

    programs.mango = {
      enable = true;
    };
    extra.gui.extraWlrInUse = ["mango"];

    xdg.portal = {
      config.mango = lib.mkForce {
        default = [ "gtk" "luminous" "wlr" ];
        "org.freedesktop.impl.portal.Settings" = [ "luminous" "wlr" ];
        "org.freedesktop.impl.portal.ScreenCast" = ["luminous"];
      };
      extraPortals = with pkgs; [
        xdg-desktop-portal-luminous
      ];
      configPackages = with pkgs; [
        xdg-desktop-portal-luminous
      ];
    };
  };

}
