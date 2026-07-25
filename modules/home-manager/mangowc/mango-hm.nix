{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.wayland.windowManager.mango;
  variables = lib.concatStringsSep " " cfg.systemd.variables;
  extraCommands = lib.concatStringsSep " && " cfg.systemd.extraCommands;
  systemdActivation = "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd ${variables}; ${extraCommands}";
  autostart_sh = pkgs.writeShellScript "autostart.sh" ''
    ${lib.optionalString cfg.systemd.enable systemdActivation}
    ${cfg.autostart_sh}
  '';
in
{
  options.wayland.windowManager.mango = {
    enable = mkEnableOption "mango window manager";

    systemd = {
      enable = mkEnableOption "systemd integration";
      xdgAutostart = mkEnableOption "xdg autostart";
      extraCommands = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
      variables = mkOption {
        type = types.listOf types.str;
        default = [
          "DISPLAY"
          "WAYLAND_DISPLAY"
          "XDG_CURRENT_DESKTOP"
          "XDG_SESSION_TYPE"
          "NIXOS_OZONE_WL"
          "XCURSOR_THEME"
          "XCURSOR_SIZE"
        ];
      };
    };

    autostart_sh = mkOption {
      type = types.lines;
      default = "";
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
    };
  };

  config = mkIf cfg.enable {
    xdg.configFile= {

    "mango/config.conf".text = cfg.extraConfig;

    "mango/autostart.sh" = mkIf (cfg.autostart_sh != "") {
      executable = true;
      source = autostart_sh;
    };
    };
  systemd.user.targets.mango-session = lib.mkIf cfg.systemd.enable {
          Unit = {
            Description = "mango compositor session";
            Documentation = [ "man:systemd.special(7)" ];
            BindsTo = [ "graphical-session.target" ];
            Wants = [
              "graphical-session-pre.target"
            ]
            ++ lib.optional cfg.systemd.xdgAutostart "xdg-desktop-autostart.target";
            After = [ "graphical-session-pre.target" ];
            Before = lib.optional cfg.systemd.xdgAutostart "xdg-desktop-autostart.target";
          };
        };
    };
}
