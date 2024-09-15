{ ... }:
{
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs = {
    extraPools = [ "Zeno" ];
    forceImportRoot = false;
  };
  services.zfs.autoScrub.enable = true;
  services.zfs.autoSnapshot = {
    enable = true;
    monthly = 5;
  };
}
