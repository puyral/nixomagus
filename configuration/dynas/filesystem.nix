{ pkgs, ... }:
{
  imports = [ ./zfs.nix ];
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
  };
  networking.hostId = "007f0200";
}
