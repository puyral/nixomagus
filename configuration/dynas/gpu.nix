{ config, pkgs, ... }:
{
  # see https://patchwork.freedesktop.org/patch/674583/?series=154480&rev=2
  # see https://gitlab.freedesktop.org/drm/xe/kernel/-/issues/6221

  boot.kernelParams = [
  ];

  # drivers 
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # QuickSync for Encoding
      intel-compute-runtime # OpenCL for Machine Learning (Immich)
      vpl-gpu-rt # Newer Video Processing Library
    ];
  };
}
