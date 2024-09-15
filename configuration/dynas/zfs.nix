{ ... }:
{
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs = {
    extraPools = [ "Zeno" ];
    forceImportRoot = false;
  };
  services.zfs.autoScrub.enable = true;

  # see https://manpages.debian.org/bookworm/zfs-auto-snapshot/zfs-auto-snapshot.8.en.html
  # for more control
  #
  # Zeno/media/videos is excluded
  services.zfs.autoSnapshot = {
    enable = true;
    monthly = 5;
  };
}
