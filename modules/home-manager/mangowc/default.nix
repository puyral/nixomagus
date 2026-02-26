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
    variables = lib.concatStringsSep " " config.wayland.windowManager.mango.systemd.variables;
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
        extraCommands = [
            "systemctl --user reset-failed"
            "systemctl --user start mango-session.target"
            "systemctl --user import-environment ${variables}"
            "systemctl --user restart xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk"
            "systemctl --user start ${config.vars.wallpaperTarget}"
        ];
      };
      autostart_sh = ''
        ${config.extra.waybar.configs.mangowc.run}
      '';
    };

    # systemd.user.services.mango-portal-init = {
    #   Unit = {
    #     Description = "Initialize portals for mango";
    #     After = [ "mango-session.target" ];
    #     PartOf = [ "mango-session.target" ];
    #   };
    #   Service = {
    #     Type = "oneshot";
    #     ExecStart = "${pkgs.writeShellScript "mango-portal-init" ''
    #       ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=mango:wlroots XDG_SESSION_TYPE=wayland XDG_DATA_DIRS XDG_CONFIG_DIRS
    #       ${pkgs.systemd}/bin/systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_DATA_DIRS XDG_CONFIG_DIRS
    #       ${pkgs.systemd}/bin/systemctl --user restart xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk
    #     ''}";
    #   };
    #   Install = {
    #     WantedBy = [ "mango-session.target" ];
    #   };
    # };

#     home.packages = with pkgs; [
#       foot
#       rofi
#       (writeShellScriptBin "test-screencast" ''
#         ${python3}/bin/python3 -c '
# import sys
# try:
#     from gi.repository import Gio
#     bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
#     proxy = Gio.DBusProxy.new_sync(bus, Gio.DBusProxyFlags.NONE, None, "org.freedesktop.portal.Desktop", "/org/freedesktop/portal/desktop", "org.freedesktop.portal.ScreenCast", None)
#     if "ScreenCast" in proxy.get_interface_name():
#         print("SUCCESS: ScreenCast interface found!")
#     else:
#         print("FAILURE: ScreenCast interface NOT found in proxy")
# except Exception as e:
#     print(f"FAILURE: {e}")
# '
#       '')
#     ];
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
