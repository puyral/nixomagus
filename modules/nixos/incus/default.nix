{lib, config, pkgs, ...}:
let cfg = config.extra.incus; in
{
 options.extra.incus = with lib; {
  enable = mkEnableOption "incus";
  admins = mkOption {
    type = types.listOf types.str;
    default = ["simon"];
  };
  users = mkOption {
    type = types.listOf types.str;
    default = [];
  };
 };

 config = lib.mkIf cfg.enable {
  virtualisation.incus= {
    enable = true;
    ui.enable = true;
    useACMEHost = config.extra.acme.domain;
    # socketActivation = true;
  };

  # https://wiki.nixos.org/wiki/Incus#Networking/Firewall
  networking.nftables.enable = true;

  users.groups.incus.members = ["root"] ++ cfg.users;
  users.groups.incus-admin.members = ["root"] ++ cfg.admins;
 };
}