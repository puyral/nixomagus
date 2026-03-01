{ lib, ... }:
with lib;

{
  options.extra.gui = {
    enable = mkEnableOption "gui";
    extraWlrInUse = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
    hyprland = mkEnableOption "hyprland";
    i3 = mkEnableOption "i3";
    sway = mkEnableOption "sway";
    mangowc = mkEnableOption "mangowm";
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
