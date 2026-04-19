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
  networking.firewall.interfaces.incusbr0.allowedTCPPorts = [
  53
  67
];
networking.firewall.interfaces.incusbr0.allowedUDPPorts = [
  53
  67
];

  users.groups.incus.members = ["root"] ++ cfg.users;
  users.groups.incus-admin.members = ["root"] ++ cfg.admins;
 };



#  config: {}
# networks:
# - config:
#     ipv4.address: auto
#     ipv6.address: auto
#   description: ""
#   name: incusbr0
#   type: ""
#   project: default
# storage_pools:
# - config:
#     source: Zeno/containers/incus
#   description: ""
#   name: zfs
#   driver: zfs
# storage_volumes: []
# profiles:
# - config: {}
#   description: ""
#   devices:
#     eth0:
#       name: eth0
#       network: incusbr0
#       type: nic
#     root:
#       path: /
#       pool: zfs
#       type: disk
#   name: default
#   project: default
# projects: []
# certificates: []
# cluster_groups: []
# cluster: null
}