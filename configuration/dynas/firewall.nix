{ ... }:
{
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      80
      443
      8384
    ];
    # allowedUDPPortRanges = [
    #   {
    #     from = 4000;
    #     to = 4007;
    #   }
    #   {
    #     from = 8000;
    #     to = 8010;
    #   }
    # ];
  };

  # networking.nat = {
  #   enable = true;
  #   internalInterfaces = ["ve-+"];
  #   externalInterface = "enp9s0";
  #   # Lazy IPv6 connectivity for the container
  #   enableIPv6 = true;
  # };

  # we want to be *sure* this is on
  services.openssh.openFirewall = true;
}
