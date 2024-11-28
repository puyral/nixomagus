{ ... }:
{
  # we want to be *sure* this is on
  services.openssh.openFirewall = true;
  services.tailscale = {
    enable = true;
    openFirewall = true;
    # useRoutingFeatures = "server";
  };
}
