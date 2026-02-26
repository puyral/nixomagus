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
    extra.gui.extraWlrInUse = [ "mango" ];

    xdg.portal = {
      config.mango = lib.mkForce {
        default = [
          "gtk"
        ];
        # except those
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "luminous" ];
        "org.freedesktop.impl.portal.ScreenShot" = [ "luminous" ];

        "org.freedesktop.impl.portal.RemoteDesktop" = [ "luminous" ];
        "org.freedesktop.impl.portal.InputCapture" = [ "luminous" ];
        "org.freedesktop.impl.portal.Settings" = [ "luminous" ];

        # wlr does not have this interface
        "org.freedesktop.impl.portal.Inhibit" = [ ];
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
