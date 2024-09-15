{ pkgs, ... }:
{
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

#    "/mnt/Zeno" = {
#  device = "Zeno";
#  fsType = "zfs";
#};
  };
  boot.supportedFilesystems = [ "zfs" ];
boot.zfs= {extraPools = [ "Zeno" ];
  	forceImportRoot = false;};
networking.hostId = "007f0200";
}
