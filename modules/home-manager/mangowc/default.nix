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
        ${config.extra.waybar.configs.mangowc.run} &
      '';
    };
  };
}
