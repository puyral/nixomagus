{ ... }:
{
  # we want to be *sure* this is on
  services.openssh.openFirewall = true;

  extra.tailscale.enable = true;
}
