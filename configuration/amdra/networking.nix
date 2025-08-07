{ ... }:
{
  services.cloudflare-warp.enable = true;
  networking.networkmanager.unmanaged = [ "interface-name:enp10s0" ];
  networking.interfaces = {
    enp10s0 = {
      wakeOnLan.enable = true;
      useDHCP = false;
      ipv4.addresses = [ ];
      ipv6.addresses = [ ];
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
