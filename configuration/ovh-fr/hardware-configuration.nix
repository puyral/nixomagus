{ modulesPath, lib, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/installer/scan/not-detected.nix")
    ./disko-config.nix
  ];
  disko.devices.disk.main.device = "/dev/sda";

  boot = {
    initrd.availableKernelModules = [
      "ata_piix"
      "uhci_hcd"
      "xen_blkfront"
      "vmw_pvscsi"
    ];
    initrd.kernelModules = [ "nvme" ];

    loader = {
      systemd-boot.enable = lib.mkForce false;
      grub = {
        enable = true;
        device = "/dev/sda";
        efiSupport = true;
        efiInstallAsRemovable = true;
      };
    };
  };
}
