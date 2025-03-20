{ ... }:
{
  networking.interfaces.enp13s0 = {
    wakeOnLan.enable = true;
    ipv4.routes = [
      {
        address = "default";
        prefixLength = 32;
        options.metric = "1";
      }
    ];
    useDHCP = true;
  };
  networking.interfaces.enp10s0 = {
    wakeOnLan.enable = true;
    useDHCP = true;
  };
}
