{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [ ../commun/filesystem.nix ];

  extra.cachefilesd.enable = true;
  fileSystems =
    let
      zeno = {
        device = "192.168.0.2:/mnt/Zeno";
        fsType = "nfs";
        options = [
          "x-systemd.automount"
          "noauto"
          "nofail"
          "x-systemd.idle-timeout=60"
          "fsc"
        ];
      };
    in
    {
      "/boot" = {
        label = "NIXBOOT";
        fsType = "vfat";
      };

      "/swap" = {
        label = "NIXROOT";
        fsType = "btrfs";
        options = [
          "subvol=swap"
          "noatime"
        ];
      };

      "${config.extra.cachefilesd.cacheDir}" = {
        label = "NIXROOT";
        fsType = "btrfs";
        options = [
          "subvol=cache"
          "compress=zstd"
          "noatime"
        ];

      };

      # "/mnt/Windows" = {
      #   device = "/dev/sda3";
      #   fsType = "ntfs-3g";
      #   options = [
      #     "rw"
      #     "uid=1000"
      #     "nofail"
      #   ];
      # };
      # "/mnt/Zeno" = zeno;
      # "/Volumes/Zeno" = zeno;

    };
  boot.supportedFilesystems = [ "nfs" ];
  swapDevices = [ ]; # [ { device = "/swap/swapfile1"; } ];
  boot.tmp.tmpfsSize = "50%";
}
