{
  lib,
  config,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  kernel = pkgs-unstable.linuxPackages_zen;
in
{
  # need the latest kernel
  #boot.kernelPackages = kernel;
  # boot.zfs.package = pkgs-unstable.zfs; # and zfs
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    amdgpu = {
      opencl.enable = true;
    };
  };

  extra.llm.acceleration = "rocm";

  vars = { inherit kernel; };
}
