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
  options.extra.virtualisation = {
    enable = lib.mkEnableOption "virtualisaiont";
    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
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

      };
      spiceUSBRedirection.enable = true;
    };
  };
}
