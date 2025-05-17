{ ... }:
{
  networking.interfaces = {
    enp10s0 = {
      wakeOnLan.enable = true;
    };
    enp15s0 = {
      wakeOnLan.enable = true;
      useDHCP = false;
      mtu = 9000;
      ipv4.addresses = [
        {
          addresse = "192.168.1.3";
          prefixLength = 24;
        }
      ];
    };
  };
  systemd.services.NetworkManager-wait-online.enable = false;
}
