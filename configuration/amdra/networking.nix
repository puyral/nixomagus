{ config, ... }:
{
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
