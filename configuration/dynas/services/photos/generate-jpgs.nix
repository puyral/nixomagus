{
  config,
  pkgs,
  pkgs-unstable,
  ...
}:
let

  gen-config = {
    dry_run = false;
    library = "/mnt/Zeno/media/darktable-database/library.db";
    jpgs = "/mnt/Zeno/media/photos/exports/complete";
    use_flatpack = false;
    quality = 80;
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
  # Define the systemd service
  systemd.services."${name}-jpgs" = {
    description = "Service to generate JPGs";
    serviceConfig = {
      ExecStart = "${generate-jpgs}/bin/generate-jpgs"; # Make sure 'yourPackage' provides 'generate-jpgs'
      User = "simon";
      Group = "photoprism";
    };
    wantedBy = [ "multi-user.target" ]; # Optional: ensure the service can be started manually
  };

  # Define the systemd timer that runs every week
  systemd.timers."${name}-timer" = {
    description = "Daily JPGs generation";
    timerConfig = {
      OnCalendar = "daily 01:00"; # At 1 AM
      Persistent = true; # Ensures the job is run if the system was off during the scheduled time
    };
    wantedBy = [ "timers.target" ]; # Makes sure the timer is started at boot
    unitConfig = {
      Requires = [ "${name}.service" ]; # Ensures the service is linked to the timer
    };
  };
}
