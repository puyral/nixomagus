{ pkgs, ... }:
{
  imports = [
    ./zfs.nix
    ../commun/filesystem.nix
  ];
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/624A-A8EF";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };

    "/containers" = {
      device = "/dev/disk/by-label/NIXROOT";
      fsType = "btrfs";
      options = [
        "subvol=containers"
        "compress=zstd"
      ];
    };
    "/swap" = {
      label = "NIXROOT";
      fsType = "btrfs";
      options = [
        "subvol=swap"
        "noatime"
      ];
    };
  };
  swapDevices = [ { device = "/swap/swapfile"; } ];
}
