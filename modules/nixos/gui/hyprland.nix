{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.extra.gui;
in
{
  config = lib.mkIf (cfg.enable && cfg.hyprland) {
    # enable hyprland
    programs.hyprland = {
      enable = true;
      package = pkgs.hyprland;
      withUWSM = true;
    };

    xdg.portal = {
      config = {
        hyprland.default = [
          "gtk"
          "hyprland"
        ];
      };
      extraPortals = [
        pkgs.xdg-desktop-portal-hyprland
      ];
    };
  };
}
