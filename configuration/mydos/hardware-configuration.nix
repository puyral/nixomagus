{
  config,
  lib,
  pkgs,
  pkgs-self,
  modulesPath,
  nixos-hardware,
  ...
}:

let
  dtx = pkgs-self.surface-dtx-daemon;
  detach = pkgs.writeShellScript "detach" (builtins.readFile ./scripts/detach.sh);
  attach = pkgs.writeShellScript "attach" (builtins.readFile ./scripts/attach.sh);
  abort-hook = pkgs.writeShellScript "abort" (builtins.readFile ./scripts/abort.sh);
in
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
  environment.systemPackages = [ dtx ] ++ (with pkgs; [ surface-control ]);
  hardware.opentabletdriver.enable = true;

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "nvme"
      "usb_storage"
      "sd_mod"
    ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
    extraModprobeConfig = ''
      softdep soc_button_array pre: pinctrl_sunrisepoint
    '';
  };

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
  zramSwap.enable = true;

  boot.tmp = {
    useTmpfs = true;
    tmpfsSize = "50%";
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp1s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;


  # Surface Book clipboard detachment daemon
  # See https://github.com/linux-surface/surface-dtx-daemon
  services.udev.packages = [ dtx ];
  services.dbus.packages = [ dtx ];

  # Register the systemd units shipped by the package and enable them
  systemd.packages = [ dtx ];
  systemd.services.surface-dtx-daemon = {
    wantedBy = [ "multi-user.target" ];
  };
  systemd.user.services.surface-dtx-userd = {
    wantedBy = [ "default.target" ];
  };

  # Configure the DTX handler hooks (TOML). Overrides the default config from the package.
  environment.etc."surface-dtx/surface-dtx-daemon.conf".text = ''
    [log]
    level = "info"

    [handler.detach]
    exec = "${detach}"

    [handler.detach_abort]
    exec = "${abort-hook}"

    [handler.attach]
    exec = "${attach}"
  '';
}
