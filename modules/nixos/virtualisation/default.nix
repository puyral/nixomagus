{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.extra.virtualisation;
in
{
  imports = [ ./passthrough.nix ];

  options.extra.virtualisation = with lib; {
    enable = mkEnableOption "virtualisation";
    users = mkOption {
      type = types.listOf types.str;
      default = [ "simon" ];
    };
  };

  config = lib.mkIf cfg.enable {
    programs.virt-manager.enable = true;

    users.groups.libvirtd.members = cfg.users;
    virtualisation = {
      libvirtd = {
        enable = true;

        qemu = {
          runAsRoot = true;
          swtpm.enable = true;
          ovmf = {
            enable = true;
            packages = [
              (pkgs.OVMF.override {
                secureBoot = true;
                tpmSupport = true;
              }).fd
            ];
          };
        };

        # Stop all running VMs on shutdown.
        onShutdown = "shutdown";

      };
      spiceUSBRedirection.enable = true;
    };
  };
}
