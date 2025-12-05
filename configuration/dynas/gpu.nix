{ config, pkgs, ... }:
{
         # see https://patchwork.freedesktop.org/patch/674583/?series=154480&rev=2
         # see https://gitlab.freedesktop.org/drm/xe/kernel/-/issues/6221



  boot.kernelParams = [
    # 1. Force ASPM (Active State Power Management)
    # This forces the link to drop to low power (L1) when idle.
    # "pcie_aspm=force"

    # 2. (Optional) Force Power Default
    # Only use this if the above isn't enough; it sets the default policy to powersave.
    # "pcie_aspm.policy=powersave"
  ];


  # boot.kernelPatches = [
  #   {
  #     name = "fix-xe-pcode-timeout";
  #     patch = pkgs.fetchurl {
  #       url = "https://patchwork.freedesktop.org/patch/674583/mbox/"; 
  #       hash = "sha256-bYSLHeI66kDKJqUIMKnpFmDsODsow3bvjS7+Yp2U6ro=";
  #     };
  #   }
  # ];

  # 3. INSTALL DRIVERS INSIDE THE CONTAINER
  # The container shares the kernel, but needs its own userspace libraries
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # QuickSync for Encoding
      intel-compute-runtime # OpenCL for Machine Learning (Immich)
      vpl-gpu-rt # Newer Video Processing Library
    ];
  };
}
