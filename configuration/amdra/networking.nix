{ config, ... }:
{
  # TODO: figure out what happend to the wifi...

  # prevent cross interface arp
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.arp_ignore" = 1;
    "net.ipv4.conf.all.arp_announce" = 2;
    "net.ipv4.conf.enp10s0.arp_ignore" = 1;
    "net.ipv4.conf.enp10s0.arp_announce" = 2;
    "net.ipv4.conf.enp15s0.arp_ignore" = 1;
    "net.ipv4.conf.enp15s0.arp_announce" = 2;
  };
  services.cloudflare-warp.enable = true;
  networking.networkmanager.unmanaged = [ "interface-name:enp15s0" ];
  networking.interfaces = {
    enp10s0 = {
      wakeOnLan.enable = true;
      useDHCP = true;
    };
    enp15s0 = {
      wakeOnLan.enable = true;
      useDHCP = false;
      mtu = 9000;
      ipv4.addresses = [
        {
          address = "192.168.128.2";
          prefixLength = 29;
        }
      ];
      ipv6.addresses = [ ];
    };
  };
  systemd.services.NetworkManager-wait-online.enable = false;

  networking.nat = {
    externalInterface = config.vars.mainNetworkInterface;

    # for backup if needed
    # externalInterface = "wlp8s0"; # wifi
  };

  vars = {
    mainNetworkInterface = "enp10s0";
    fastIp = "192.168.128.2";
  };
}
