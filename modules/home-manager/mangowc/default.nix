{
  config,
  lib,
  mangowc,
  pkgs,
  ...
}:
let
  cfg = config.extra.mangowc;
in
{
  imports = [
    mangowc.hmModules.mango
    ./waybar.nix
    ./settings.nix
  ];

  options.extra.mangowc.enable = lib.mkEnableOption "mangowc";

  config = lib.mkIf cfg.enable {
    extra.waybar.enable = true;
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
