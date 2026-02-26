{
  config,
  lib,
  mangowc,
  pkgs,
  ...
}:
let
  cfg = config.extra.mangowc;

  coestr = with lib; types.coercedTo types.int toString types.str;
  coeListOf = with lib; t: types.coercedTo t (x: [ x ]) (types.listOf t);
in
{
  imports = [
    mangowc.hmModules.mango
    ./waybar.nix
    ./settings.nix
  ];

  options.extra.mangowc = with lib; {
    enable = mkEnableOption "mangowc";
    monitors = mkOption {
      type = with types; coeListOf (attrsOf coestr);
    };
  };

  config = lib.mkIf cfg.enable {
    extra = {
      waybar.enable = true;
      wallpaper.enable = true;
      anyrun.enable = true;
    };
    wayland.windowManager.mango = {
      enable = true;
      systemd = {
        enable = true;
        xdgAutostart = true;
      };
    };
    home.packages = with pkgs; [
      foot
      rofi
    ];
    # home.xdg.portal = {
    #   enable = true;
    #   # xdgOpenUsePortal = true;
    #   config = {
    #     mango = {
    #       default = [
    #         "gtk"
    #       ];
    #       # except those
    #       "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
    #       "org.freedesktop.impl.portal.ScreenCast" = ["wlr"];
    #       "org.freedesktop.impl.portal.ScreenShot" = ["wlr"];

    #       # wlr does not have this interface
    #       "org.freedesktop.impl.portal.Inhibit" = [];
    #     };
    #   };
    #   extraPortals = with pkgs; [
    #     xdg-desktop-portal-wlr
    #     xdg-desktop-portal-gtk
    #   ];
    # };
  };
}
