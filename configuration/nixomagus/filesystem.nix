{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [ ../commun/filesystem.nix ];

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };
    "/Volumes/Zeno/media/photos" = {
      device = "/dev/disk/by-label/NIXROOT";
      fsType = "btrfs";
      options = [
        "subvol=photos"
        "compress=zstd"
      ];
    };

    #  "/mnt/Windows" = {
    #    device = "/dev/sda3";
    #    fsType = "ntfs-3g";
    #    options = [
    #      "rw"
    #      "uid=1000"
    #    ];
    #  };

    "/swap" = {
      label = "NIXROOT";
      fsType = "btrfs";
      options = [
        "subvol=swap"
        "noatime"
      ];
    };

    # "/mnt/Zeno" = {
    #   device = "192.168.0.2:/mnt/Zeno";
    #   fsType = "nfs";
    #   options = [
    #     "x-systemd.automount"
    #     "noauto"
    #     "x-systemd.idle-timeout=600"
    #   ];
    # };
  };
  swapDevices = [ { device = "/swap/swapfile1"; } ];
}
