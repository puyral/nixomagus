{
  config,
  pkgs,
  lib,
  pkgs-self,
  ...
}:
let
  cfg = config.extra.generate-jpgs;

  jpgsDir = "/exports";

  gen-config = {
    dry_run = cfg.dry_run;
    library = cfg.locations.library;
    jpgs = cfg.locations.export;
    use_flatpack = false;
    quality = 80;
    stateless = true;
  }
  // cfg.extraConfig;

  generate-jpgs = pkgs-self.generate-jpgs.override {
    inherit gen-config;
  };
  name = "photos-generate-jpgs";
in
{
  options.extra.generate-jpgs = with lib; {
    enable = mkEnableOption "generate jpgs";
    dry_run = mkOption {
      type = types.bool;
      default = false;
    };

    library = mkOption {
      type = types.path;
    };
    locations = {
      library = mkOption {
        type = types.path;
      };
      export = mkOption {
        type = types.path;
        # default = "${cfg.locations.originals}/exports/complete";
      };
      # originals = mkOption {
      #   type = types.path;
      #   default = "/Volumes/Zeno/media/photos";
      # };
    };
    extraConfig = mkOption {
      type = types.attrs;
      default = { };
    };
    onTimer = {
      enable = mkEnableOption "timer";
    };
    extraServiceConfig = mkOption {
      type = types.attrs;
      default = { };
    };
  };

  config.systemd.user = lib.mkIf cfg.enable {
    # Define the systemd service
    services."${name}" = {
      Unit.Description = "Service to generate JPGs";
      Service = {
        ExecStart = "${generate-jpgs}/bin/generate-jpgs"; # Make sure 'yourPackage' provides 'generate-jpgs'
        # BindPaths = lib.concatStringsSep " " [
        #   "${cfg.locations.originals}:/Volumes/Zeno/media/photos"
        #   "${cfg.locations.export}:${jpgsDir}"
        #   "${generate-jpgs}:${generate-jpgs}"
        # ];
      }
      // cfg.extraServiceConfig;
      Install.WantedBy = [ ]; # Optional: ensure the service can be started manually
    };

    # Define the systemd timer that runs every week
    timers = lib.mkIf cfg.onTimer.enable {
      "${name}" = {
        Timer = {
          OnCalendar = "*-*-* 1:00:00"; # At 1 AM
          Persistent = true; # Ensures the job is run if the system was off during the scheduled time
        };
        Install.WantedBy = [ "timers.target" ]; # Makes sure the timer is started at boot
        Unit = {
          Description = "Daily JPGs generation";
          Requires = [ "${name}.service" ]; # Ensures the service is linked to the timer
        };
      };
    };
  };
}
