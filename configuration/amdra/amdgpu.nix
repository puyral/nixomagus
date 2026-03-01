{
  lib,
  config,
  pkgs,
  pkgs-unstable,
  ...
}:
{
  nixpkgs.config.rocmSupport = true;

  # need the latest kernel
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
}
