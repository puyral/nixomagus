{
  config,
  rootDir,
  ...
}:
{
  boot = {
    supportedFilesystems = [ "zfs" ];
    zfs = {
      extraPools = [ "Zeno" ];
      forceImportRoot = true;
    };
    kernel.sysctl = {
      "vfs.zfs.l2arc_rebuild_enabled" = 1;
    };
  };
  networking.hostId = "007f0200";

  # see https://manpages.debian.org/bookworm/zfs-auto-snapshot/zfs-auto-snapshot.8.en.html
  # for more control
  #
  # Zeno/media/videos is excluded
  services.zfs = {
    autoSnapshot = {
      enable = true;
      monthly = 5;
      flags = "-k -p -v --utc";
    };
    autoScrub.enable = true;

    zed = {
      settings = {
        ZED_EMAIL_ADDR = [
          "admin@puyral.fr"
        ];

        ZED_NOTIFY_INTERVAL_SECS = 3600;
        ZED_NOTIFY_VERBOSE = true;

        ZED_SCRUB_AFTER_RESILVER = true;
      };
    };
  };

  vars.Zeno.mountPoint = "/mnt/Zeno";
}
