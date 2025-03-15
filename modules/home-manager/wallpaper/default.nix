{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.extra.xwallpaper;
in
{

  options.extra.wallpaper = {
    enable = mkEnableOption "wallpaper";
    path = mkOption {
      description = "path to the pictures";
      default = "/Volumes/Zeno/media/photos/wallpaper";
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
        duration = "${cfg.duration}s";
        sorting = "random";
      };
    };
  };
}
