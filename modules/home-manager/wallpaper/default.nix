{
  config,
  pkgs,
  lib,
  pkgs-self,
  ...
}:
with lib;
let
  cfg = config.extra.wallpaper;
  deamon = "swww-deamon";
  wp-change = "swww-change-wallpaper";
  timer = "wallpaper";
  target = "wallpaper";
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
  # config.programs.wpaperd = lib.mkIf cfg.enable {
  #   # enable = true;
  #   settings = {
  #     default = {
  #       path = cfg.path;
  #       duration = "${builtins.toString cfg.duration}s";
  #       sorting = "random";
  #     };
  #   };
  # };

  config = lib.mkIf cfg.enable {

    # Service to start swww-daemon
    systemd.user = {
      services.${deamon} = {
        Install.WantedBy = [ ];
        Service = {
          ExecStart = "${pkgs.swww}/bin/swww-daemon";
          Restart = "always";
        };
        Unit.Description = "The swww deamon";
      };

      # Service to change wallpaper randomly every 3 minutes
      services.${wp-change} = {
        Install.WantedBy = [ ];
        Service = {
          ExecStart = "${pkgs-self.swww-change-wp}/bin/swww-change-wp '${cfg.path}' --resize crop --transition-fps 60 ";
        };
        Unit = {
          Description = "Change the wallpaper using swww";
          Requires = [ "${deamon}.service" ];
          After = [ "${deamon}.service" ];
        };
      };

      # Timer to trigger the service every 3 minutes
      timers.${wp-change} = {
        Install.WantedBy = [ ];
        Timer = {
          OnUnitActiveSec = "${builtins.toString cfg.duration}s";
        };
        Unit = {
          Description = "Timer to track when to change  swww-wallpaper";
          Requires = [ "${wp-change}.service" ];
        };
      };

      targets.${target} = {
        Unit = {
          Description = "Wallpaper target";
          Requires = [
            "${wp-change}.timer"
            "${wp-change}.service"
          ];
        };
      };
    };
    vars.wallpaperTarget = "${target}.target";
  };
}
