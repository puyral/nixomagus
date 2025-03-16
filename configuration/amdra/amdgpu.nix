{
  lib,
  config,
  pkgs,
  pkgs-unstable,
  ...
}:
{
  # need the latest kernel
  boot.kernelPackages = pkgs-unstable.linuxPackages_zen;
  boot.zfs.package = pkgs-unstable.zfs; # and zfs
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.graphics.extraPackages = with pkgs-unstable; [
    rocmPackages.clr.icd
    clinfo
  ];
}
