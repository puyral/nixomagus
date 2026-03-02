{ config, ... }:
{
  networking.networkmanager.unmanaged = [ "interface-name:enp13s0" ];
  networking.interfaces.enp13s0 = {
    wakeOnLan.enable = true;
    useDHCP = false;
    mtu = 9000;
    ipv4.addresses = [
      {
        address = "192.168.128.1";
        prefixLength = 29;
      }
    ];
    ipv6.addresses = [];
  };
  networking.interfaces.enp10s0 = {
    wakeOnLan.enable = true;
    useDHCP = true;
  };
  networking.nat = {
    externalInterface = config.vars.mainNetworkInterface;

    # for backup if needed
    # externalInterface = "wlp8s0"; # wifi
  };
  vars = {
    mainNetworkInterface = "enp10s0";
    fastIp = "192.168.128.1";
  };
}
