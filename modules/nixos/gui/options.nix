{ lib, ... }:
with lib;

{
  options.extra.gui = {
    enable = mkEnableOption "gui";
    hyprland = mkEnableOption "hyprland";
    i3 = mkEnableOption "i3";
    sway = mkEnableOption "sway";
    mangowm = mkEnableOption "mangowm";
    gnome = mkOption {
      description = "enable gnome";
      default = true;
      type = types.bool;
    };
    is_docked = mkOption {
      type = types.bool;
      default = false;
    };
  };
}
