{ ... }:
{
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      80
      443
    ];
    allowedUDPPortRanges = [
      {
        from = 4000;
        to = 4007;
      }
      {
        from = 8000;
        to = 8010;
      }
    ];
  };

  # we want to be *sure* this is on
  services.openssh.openFirewall = true;
}
