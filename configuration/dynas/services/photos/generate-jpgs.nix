{
  config,
  pkgs,
  pkgs-unstable,
  ...
}:
let

  gen-config = {
    dry_run = false;
    library = "/library.db";
    jpgs = "/originals";
    use_flatpack = false;
    quality = 70;
  };

  generate-jpgs = (
    pkgs.callPackage ./generate-jpgs-pkg.nix {
      inherit gen-config;
      darktable = pkgs-unstable.darktable;
    }
  );
in
{
  # Define the systemd service
  systemd.services.generate-jpgs = {
    description = "Service to generate JPGs";
    serviceConfig = {
      ExecStart = "${generate-jpgs}/bin/generate-jpgs"; # Make sure 'yourPackage' provides 'generate-jpgs'
    };
    wantedBy = [ "multi-user.target" ]; # Optional: ensure the service can be started manually
  };

  # Define the systemd timer that runs every week
  systemd.timers.generate-jpgs-timer = {
    description = "Weekly JPGs generation";
    timerConfig = {
      OnCalendar = "daily 01:00";    # At 1 AM
      Persistent = true; # Ensures the job is run if the system was off during the scheduled time
    };
    wantedBy = [ "timers.target" ]; # Makes sure the timer is started at boot
    unitConfig = {
      Requires = [ "generate-jpgs.service" ]; # Ensures the service is linked to the timer
    };
  };
}
