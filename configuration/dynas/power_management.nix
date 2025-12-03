{ ... }:
{
  # powerManagement.powertop.enable = true;

  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  # deactivate wifi
  boot.blacklistedKernelModules = [
    "iwlwifi"
    "iwlmvm"
    "btusb"
  ];

  boot.kernelParams = [ "consoleblank=120" ];

  # TLP is excellent for managing PCIe power states automatically.
  services.tlp = {
    enable = true;
    settings = {
      # --- GPU / PCIe Power Saving (Critical for Arc B580) ---
      # "powersupersave" enables L1 states.
      # Since you fixed your BIOS, we usually don't need 'force' in the kernel anymore.
      "PCIE_ASPM_ON_AC" = "powersave";

      # "auto" allows devices to suspend (D3 state)
      "RUNTIME_PM_ON_AC" = "auto";

      # --- THE CRASH FIX ---
      # This prevents TLP from suspending the Wi-Fi card (08:00.0).
      # Note: Use "RUNTIME_PM_BLACKLIST" if you are on an older TLP version,
      # but "DENYLIST" is the modern standard.
      "RUNTIME_PM_DENYLIST" = "08:00.0 07:01.0 07:03.0 07:05.0 07:07.0";

      # --- General NAS Power Saving ---
      # "powersave" governor keeps CPU clocks low when idle (great for 3€/W bill)
      "CPU_SCALING_GOVERNOR_ON_AC" = "powersave";

      # Intel P-State hint (EPP). "power" = favor efficiency heavily.
      # If the NAS feels sluggish, change this to "balance_power".
      "CPU_ENERGY_PERF_POLICY_ON_AC" = "power";

      # (Optional) Spin down hard drives after 20 mins (240 * 5sec) idle.
      # CAUTION: Only use if your drives support it.
      # "DISK_DEVICES" = "sda sdb";
      # "DISK_SPINDOWN_TIMEOUT_ON_AC" = "240";
    };
  };
}
