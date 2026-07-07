{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.wayland.windowManager.mango;
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
    xdg.configFile."mango/config.conf".text = cfg.extraConfig;

    xdg.configFile."mango/autostart.sh" = mkIf (cfg.autostart_sh != "") {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${cfg.autostart_sh}
      '';
    };

    systemd.user.targets.mango-session = mkIf cfg.systemd.enable {
      Unit = {
        Description = "mango compositor session";
        BindsTo = [ "graphical-session.target" ];
        Wants = [ "graphical-session-pre.target" ];
        After = [ "graphical-session-pre.target" ];
      };
    };
  };
}
