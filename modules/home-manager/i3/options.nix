{ lib, config, ... }:
with lib;
{
  options.extra.i3 = {
    enable = mkEnableOption "i3";
    xrandr = mkOption {
      type = types.str;
      description = "the arguments to xrandr to set up the screen";
      example = "--output eDP-1-1 --mode 1920x1080 --rotate normal --output DP-1-1 --off --output HDMI-1-1 --off";
    };
  };
}
