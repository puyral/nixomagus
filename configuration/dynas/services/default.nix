{ pkgs, config, ... }:
{
  imports = [
    ./nfs.nix
    ./samba.nix
    ./cockpit.nix
    ./syncthing.nix
    # ./whatchtower.nix
    ./jellyfin.nix
    ./traefik
    ./homeassistant
    ./docker-test.nix
  ];

  networking.nat.enable = true;
  networking.nat.externalInterface = "enp9s0";
}
