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
  ];

  options.extra.mangowc.enable = lib.mkEnableOption "mangowc";

  config = lib.mkIf cfg.enable {
    extra.waybar.enable = true;
    wayland.windowManager.mango = {
      enable = true;
      settings = lib.strings.concatStringsSep "\n" [
        (builtins.readFile ./config.conf)
      ];
      autostart_sh = ''
        ${config.extra.waybar.configs.mangowc.run}
      '';
    };
    home.packages = with pkgs; [
      foot
      rofi
    ];
  };
}
