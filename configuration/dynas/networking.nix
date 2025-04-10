{ ... }:
{
  networking.interfaces.enp13s0 = {
    wakeOnLan.enable = true;
    useDHCP = true;
  };
  networking.interfaces.enp10s0 = {
    wakeOnLan.enable = true;
    useDHCP = true;
  };
  vars.mainNetworkInterface = "enp13s0";
}
