{
  config,
  pkgs,
  lib,
  ...
}:
{
  # 1. Ensure you are running a very recent kernel.
  # The Intel Arc B580 (Battlemage) requires Linux 6.12+ for proper power management.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # 2. Kernel Parameters
  # "pcie_aspm=force": Forces ASPM even if the BIOS suggests otherwise (often needed for Arc).
  # "consoleblank=120": Turns off the screen output after 2 mins (good for NanoKVM/burn-in).
  boot.kernelParams = [
    "consoleblank=120"
    "pcie_aspm=force"
  ];

  # 3. Disable Wifi drivers completely at the kernel level
  # This is cleaner than TLP blacklist for device 08:00.0
  boot.blacklistedKernelModules = [
    "iwlwifi"
    "iwlmvm"
    "btusb"
  ];

  # 4. Power Management Services
  services.tlp = {
    enable = true;
    settings = {
      # --- PCIe ASPM (Critical for Arc B580) ---
      # "powersupersave" allows the deepest sleep states (L1).
      # Without this, the B580 will likely stay hot.
      "PCIE_ASPM_ON_AC" = "powersupersave";

      # --- Runtime Power Management ---
      # "auto" is good for the GPU and general chipset, BUT we must whitelist specific devices below.
      "RUNTIME_PM_ON_AC" = "auto";

      # --- THE DENYLIST (The Fix for SSH & Stability) ---
      # Prevents TLP from suspending these specific devices.
      # 08:00.0 : Intel Wifi (Just in case module blacklist fails)
      # 0d:00.0 : Aquantia 10GbE (Fixes unstable connection)
      # 0a:00.0 : Intel I211 1GbE (Fixes SSH stability if connected here)
      # 0c:00.0 : LSI SAS2008 (Enterprise storage controllers crash if suspended)
      # 02:00.0 : AMD USB Controller (Keep USB active for NanoKVM input)
      # 10:00.0 : DO NOT ADD THE GPU HERE. The GPU *needs* to suspend to save power.
      "RUNTIME_PM_DENYLIST" = "08:00.0 0d:00.0 0a:00.0 0c:00.0 02:00.0";

      # --- CPU Power Saving ---
      # For a NAS, we want efficiency.
      "CPU_SCALING_GOVERNOR_ON_AC" = "powersave";
      "CPU_ENERGY_PERF_POLICY_ON_AC" = "balance_power"; # 'power' can be too slow for 10GbE interrupt handling

      # --- Disk Spindown ---
      # Only spin down rotating rust (SATA). Don't touch NVMe here.
      # Identify your HDDs via `lsblk` first. Assuming sda/sdb here.
      # "DISK_DEVICES" = "sda sdb";
      # "DISK_SPINDOWN_TIMEOUT_ON_AC" = "240"; # 20 minutes

      # --- USB ---
      # Disable USB autosuspend to ensure NanoKVM keyboard/mouse emulation never sleeps
      "USB_AUTOSUSPEND" = "0";
    };
  };

  # Disable system sleep targets to prevent accidental hibernation
  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };
}
