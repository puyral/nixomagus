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
  # boot.zfs.package = pkgs-unstable.zfs; # and zfs
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs-unstable; [
        rocmPackages.clr.icd
        clinfo
      ];
    };
    # amdgpu.amdvlk = {
    #   enable = true;
    #   support32Bit.enable = true;
    # };
  };
}
