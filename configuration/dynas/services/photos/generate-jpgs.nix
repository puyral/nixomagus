{
  config,
  pkgs,
  pkgs-unstable,
  lib,
  ...
}:
let
  cfg = config.extra.generate-jpgs;

  gen-config = {
    dry_run = cfg.dry_run;
    library = "/mnt/Zeno/media/darktable-database/library.db";
    jpgs = "/originals";
    use_flatpack = false;
    quality = 80;
    stateless = true;
  };

  generate-jpgs = (
    pkgs.callPackage ./generate-jpgs-pkg.nix {
      inherit gen-config;
      darktable = pkgs-unstable.darktable;
    }
  );
  name = "photos-generate-jpgs";
in
{
  options.extra.generate-jpgs = {
    enable = lib.mkEnableOption "generate jpgs";
    dry_run = lib.mkOption {
      type = lib.types.bool;
      default = false;
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
          "/mnt/Zeno/media/photos:/Volumes/Zeno/media/photos"
          "/mnt/Zeno/media/photos/exports/complete:/originals"
        ];
      };
      wantedBy = [ "multi-user.target" ]; # Optional: ensure the service can be started manually
    };

    # Define the systemd timer that runs every week
    systemd.timers."${name}" = {
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
}
