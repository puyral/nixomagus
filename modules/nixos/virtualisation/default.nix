{ config, lib, ... }:
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
      libvirtd.enable = true;
      spiceUSBRedirection.enable = true;
    };
  };
}
