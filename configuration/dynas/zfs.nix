{
  config,
  rootDir,
  pkgs,
  ...
}:
let
  # Logic to safely select ZFS package
  # We want the latest kernel, which might break ZFS Stable.
  # If so, we warn and fallback to ZFS Unstable.
  kernelPackages = config.boot.kernelPackages;
  stableAttr = pkgs.zfs.kernelModuleAttribute; # e.g. "zfs_2_3"
  zfsStable = kernelPackages.${stableAttr};
  zfsUnstable = kernelPackages.zfs_unstable;

  isBroken = pkg: pkg.meta.broken or false;

  zfsPackage =
    if (isBroken zfsStable) then
      builtins.warn
        "ZFS Stable (${stableAttr}) is broken on kernel ${kernelPackages.kernel.version}. Fallback to ZFS Unstable."
        zfsUnstable
    else
      zfsStable;
in
{
  boot = {
    supportedFilesystems = [ "zfs" ];
    zfs = {
      package = zfsPackage;
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
          ((import (rootDir + /secrets/email.nix)).gmail "zfs+${config.networking.hostName}")
        ];
        # ZED_EMAIL_ADDR = ["root"];
        # ZED_EMAIL_OPTS = " @ADDRESS@";

        ZED_NOTIFY_INTERVAL_SECS = 3600;
        ZED_NOTIFY_VERBOSE = true;

        # ZED_USE_ENCLOSURE_LEDS = true;
        ZED_SCRUB_AFTER_RESILVER = true;
      };
    };
  };

  vars.Zeno.mountPoint = "/mnt/Zeno";
}
