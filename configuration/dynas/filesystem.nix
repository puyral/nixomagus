{ ... }:
{
  fileSystems = {
    "/containers" = {
      device = "/dev/disk/by-label/NIXROOT";
      fsType = "btrfs";
      options = [
        "subvol=containers"
        "compress=zstd"
      ];
    };
  };
}
