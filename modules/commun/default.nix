{ ... }:
{
  modules.nixos = [ "tailscale_ips" ];
  modules.homeManager = [ "tailscale_ips" ];
  flake = {
    nixosModules.tailscale_ips = ./tailscale;
    homeModules.tailscale_ips = ./tailscale;
  };
}
