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
      type = with types; coeListOf (attrsOf str);
    };
  };

  config = lib.mkIf cfg.enable {
    extra.waybar.enable = true;
    extra.wallpaper.enable = true;
    wayland.windowManager.mango = {
      enable = true;
      autostart_sh = ''
        ${config.extra.waybar.configs.mangowc.run} &
      '';
    };
    home.packages = with pkgs; [
      foot
      rofi
    ];
  };
}
