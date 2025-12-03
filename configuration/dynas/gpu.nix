{ config, pkgs, ... }:
{
  boot.kernelParams = [
    # 1. Force ASPM (Active State Power Management)
    # This forces the link to drop to low power (L1) when idle.
    # "pcie_aspm=force"

    # 2. (Optional) Force Power Default
    # Only use this if the above isn't enough; it sets the default policy to powersave.
    # "pcie_aspm.policy=powersave"
  ];

  # 3. Enable Power Management Tuning
  # TLP is excellent for managing PCIe power states automatically.
  services.tlp = {
    enable = true;
    settings = {
      # This ensures the GPU is allowed to sleep
      RUNTIME_PM_ON_AC = "auto";
      # PCIE_ASPM_ON_AC = "powersupersave";
      PCIE_ASPM_ON_AC = "default";

      # "RUNTIME_PM_BLACKLIST" = "08:00.0"; # Replace with your actual Wi-Fi PCI ID
    };
  };

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
