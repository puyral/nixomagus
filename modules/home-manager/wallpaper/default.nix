{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.extra.wallpaper;
in
{

  options.extra.wallpaper = {
    enable = mkEnableOption "wallpaper";
    path = mkOption {
      description = "path to the pictures";
      default = "/home/simon/Pictures/Wallpapers";
      type = types.path;
    };
    duration = mkOption {
      type = types.int;
      default = 120;
    };
  };
  config.services.wpaperd = lib.mkIf cfg.enable {
    # enable = true;
    settings = {
      default = {
        path = cfg.path;
        duration = "${cfg.duration}s";
        sorting = "random";
      };
    };
  };
}
