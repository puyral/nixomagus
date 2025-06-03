{ ... }:
{
  services.cloudflare-warp.enable = true;
  networking.interfaces = {
    enp10s0 = {
      wakeOnLan.enable = true;
    };
    enp15s0 = {
      wakeOnLan.enable = true;
      useDHCP = true;
      # mtu = 9000;
      # ipv4.addresses = [
      #   {
      #     address = "192.168.1.3";
      #     prefixLength = 24;
      #   }
      # ];
      # ipv6.addresses = [];
    };
  };
  systemd.services.NetworkManager-wait-online.enable = false;
}
