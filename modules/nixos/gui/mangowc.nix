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
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
        "org.freedesktop.impl.portal.ScreenShot" = [ "wlr" ];
      };
    };

    # Force the portals to think they are in a wlroots session so they load the wlr backend
    # systemd.user.services.xdg-desktop-portal = {
    #   serviceConfig.Environment = [ "XDG_CURRENT_DESKTOP=wlroots" ];
    # };
    # systemd.user.services.xdg-desktop-portal-wlr = {
    #   serviceConfig.Environment = [ "XDG_CURRENT_DESKTOP=wlroots" ];
    # };
  };

}
