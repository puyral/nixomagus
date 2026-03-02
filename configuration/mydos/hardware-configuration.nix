{
  config,
  lib,
  pkgs,
  modulesPath,
  nixos-hardware,
  ...
}:

{
  # see https://github.com/linux-surface/linux-surface/wiki/Installation-and-Setup

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    nixos-hardware.nixosModules.microsoft-surface-common
  ];

  hardware.microsoft-surface.kernelVersion = "stable";

  # microsoft-surface-surface-pro-intel

  # microsoft-surface.ipts.enable = true;
  # microsoft-surface.surface-control.enable = true;
  environment.systemPackages = with pkgs; [ surface-control ];
  hardware.opentabletdriver.enable = true;

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/7de31426-4ab0-47aa-a8ce-6bbbab90b69e";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/EFI";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [ { device = "/swap/swapfile"; } ];

  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "50%";

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp1s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  zramSwap.enable = true;
}
