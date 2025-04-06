{
  config,
  pkgs,
  pkgs-unstable,
  lib,
  ...
}:
let
  cfg = config.extra.generate-jpgs;

  jpgsDir = "/exports";

  gen-config = {
    dry_run = cfg.dry_run;
    library = cfg.locations.library;
    jpgs = jpgsDir;
    use_flatpack = false;
    quality = 80;
    stateless = true;
  } // cfg.extraConfig;

  generate-jpgs = (
    pkgs.callPackage ./generate-jpgs-pkg.nix {
      inherit gen-config;
      darktable = pkgs-unstable.darktable;
    }
  );
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
    locations =
      let
        popt = mkOption { type = types.path; };
      in
      {
        library = popt;
        export = popt;
        originals = popts;
      };
    extraConfig = mkOption {
      type = types.attrs;
      default = { };
    };
    onTimer = {
      mkEnableOption = "time";
    };
  };

  config = lib.mkIf cfg.enable {
    # Define the systemd service
    systemd.services."${name}" = {
      description = "Service to generate JPGs";
      serviceConfig = {
        ExecStart = "${generate-jpgs}/bin/generate-jpgs"; # Make sure 'yourPackage' provides 'generate-jpgs'
        User = "simon";
        Group = "photoprism";
        BindPaths = lib.concatStringsSep " " [
          "${cfg.locations.originals}:/Volumes/Zeno/media/photos"
          "${cfg.locations.export}:${jpgsDir}"
        ];
      };
      wantedBy = [ "multi-user.target" ]; # Optional: ensure the service can be started manually
    };

    # Define the systemd timer that runs every week
    systemd.timers = lib.mkIf cfg.onTimer.enable {
      "${name}" = {
        description = "Daily JPGs generation";
        timerConfig = {
          OnCalendar = "*-*-* 1:00:00"; # At 1 AM
          Persistent = true; # Ensures the job is run if the system was off during the scheduled time
        };
        wantedBy = [ "timers.target" ]; # Makes sure the timer is started at boot
        unitConfig = {
          Requires = [ "${name}.service" ]; # Ensures the service is linked to the timer
        };
      };
    };
  };
}
