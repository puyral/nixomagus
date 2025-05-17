{ ... }:
{
  networking.interfaces.enp13s0 = {
    wakeOnLan.enable = true;
    useDHCP = true;
    # mtu = 9000;
    # ipv4.addresses = [
    #   {
    #     address = "192.168.1.2";
    #     prefixLength = 24;
    #   }
    # ];
  };
  networking.interfaces.enp10s0 = {
    wakeOnLan.enable = true;
    useDHCP = true;
  };
  vars = {
    mainNetworkInterface = "enp13s0";
    fastIp = "192.168.0.2";
  };
}
