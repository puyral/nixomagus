{
  lib,
  config,
  pkgs,
  pkgs-unstable,
  ...
}:
{
  boot.kernelPackages = pkgs-unstable.linuxPackages_zen;
  # boot.zfs.package = pkgs-unstable.zfs_2_3_1;
}
