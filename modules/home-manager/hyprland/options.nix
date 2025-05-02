{ lib, ... }:
with lib;
{
  options.extra.hyprland = {
    enable = mkEnableOption "hyprland";
    monitors = mkOption {
      type = with types; listOf (listOf str);
      description = "the monitor used in hyprland";
      example = [
        [
          "HDMI-A-2"
          "3840x2160"
          "1280x0"
          "1"
          "bitdepth"
          "10"
        ]
        [
          "eDP-1"
          "disable"
        ]
        [
          "DP-2"
          "1280x1024"
          "0x0"
          "1"
        ]
      ];
    };
    extraSettings = mkOption {
      type = types.attrs;
      default = { };
    };
  };
}
