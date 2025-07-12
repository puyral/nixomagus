{ lib, ... }:
with lib;

{
  options.extra.gui = {
    enable = mkEnableOption "gui";
    hyprland = mkEnableOption "hyprland";
    i3 = mkEnableOption "i3";
    sway = mkEnableOption "sway";
    gnome = mkOption {
      description = "enable gnome";
      default = true;
      type = types.bool;
    };
  };
}
