# based on https://astrid.tech/2022/09/22/0/nixos-gpu-vfio/ and https://kilo.bytesize.xyz/gpu-passthrough-on-nixos
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.extra.virtualisation.passthrough;
  enable = config.extra.virtualisation.enable && cfg.enable;
in
{
  options.extra.virtualisation = with lib; {
    passthrough = {
      enable = mkEnableOption "GPU passthrough";
      ids = mkOption {
        type = with types; listOf str;
      };
      plateform = mkOption {
        type = types.str;
        default = "amd";
      };
      user = mkOption {
        type = types.str;
        default = "simon";
      };
    };
  };

  config = lib.mkIf enable {
    boot = {
      kernelParams = [
        "${cfg.plateform}_iommu=on"
        "vfio-pci.ids=${builtins.concatStringsSep "," cfg.ids}"
        #        "${cfg.plateform}_iommu=pt"
        #        "kvm.ignore_msrs=1"
      ];
      initrd.kernelModules = [
        "vfio_pci"
        "vfio"
        "vfio_iommu_type1"

        # no longer needed
        # https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#mkinitcpio
        # "vfio_virqfd"
      ];
      #      extraModprobeConfig = "options vfio-pci ids=${builtins.concatStringsSep "," cfg.ids}";
    };

    # Add virt-manager and looking-glass to use later.
    environment.systemPackages = with pkgs; [
      looking-glass-client
    ];

    systemd.tmpfiles.rules = [
      "f /dev/shm/looking-glass 0660 ${cfg.user} qemu-libvirtd -"
    ];
  };
}
