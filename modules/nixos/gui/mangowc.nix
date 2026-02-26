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
    extra.gui.extraWlrInUse = ["mango"];

    xdg.portal.config = {
      mango = lib.mkForce {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
        "org.freedesktop.impl.portal.ScreenShot" = [ "wlr" ];
      };
    };
  };

}
