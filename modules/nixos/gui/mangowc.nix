{
  config,
  lib,
  mangowc,
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

    xdg.portal.config = {
      mango = lib.mkForce {
        default = "gtk;hyprland";
      };

      # default from the mango module
      # mango = {
      #     default = [
      #       "gtk"
      #     ];
      #     # except those
      #     "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
      #     "org.freedesktop.impl.portal.ScreenCast" = ["wlr"];
      #     "org.freedesktop.impl.portal.ScreenShot" = ["wlr"];

      #     # wlr does not have this interface
      #     "org.freedesktop.impl.portal.Inhibit" = [];
      #   };
    };
  };

}
