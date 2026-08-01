{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.extra.incus;
  trustedPorts = [
    53
    67
    22
  ]
  ++ cfg.extraPorts;

in
{
  options.extra.incus = with lib; {
    enable = mkEnableOption "incus";
    admins = mkOption {
      type = types.listOf types.str;
      default = [ "simon" ];
    };
    users = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
    extraPorts = mkOption {
      type = types.listOf types.port;
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.incus = {
      enable = true;
      ui.enable = true;
      useACMEHost = config.extra.acme.domain;
      # socketActivation = true;
    };

    # https://wiki.nixos.org/wiki/Incus#Networking/Firewall
    networking.nftables.enable = true;
    networking.firewall.interfaces.incusbr0.allowedTCPPorts = trustedPorts;
    networking.firewall.interfaces.incusbr0.allowedUDPPorts = trustedPorts;

    users.groups.incus.members = [ "root" ] ++ cfg.users;
    users.groups.incus-admin.members = [ "root" ] ++ cfg.admins;


    systemd.services.incus = {
  # Starting AFTER these targets means systemd will stop Incus BEFORE them during shutdown.
  after = [ 
    "network.target" 
    "network-online.target" 
    "zfs.target" 
    "zfs-mount.service" 
  ];
  wants = [ "network-online.target" ];
  
  # This is the most bulletproof directive for storage hangs. 
  # It strictly prohibits systemd from unmounting the underlying path until the service exits.
  # Adjust this path if your Incus storage pool is mounted elsewhere on your Zeno pool.
  unitConfig.RequiresMountsFor = "/var/lib/incus"; 
};
  };

}