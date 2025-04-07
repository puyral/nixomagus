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
  config.programs.wpaperd = lib.mkIf cfg.enable {
    # enable = true;
    settings = {
      default = {
        path = cfg.path;
        duration = "${builtins.toString cfg.duration}s";
        sorting = "random";
      };
    };
  };
}
