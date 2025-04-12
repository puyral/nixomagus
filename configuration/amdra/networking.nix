{ ... }:
{
  networking.interfaces = {
    enp10s0 = {
      wakeOnLan.enable = true;
    };
    enp15s0 = {
      wakeOnLan.enable = true;
    };
  };
}
