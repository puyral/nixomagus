{ pkgs, config, ... }:
{
  imports = [
    ./nfs.nix
    ./samba.nix
    ./cockpit.nix
    ./syncthing.nix
    ./whatchtower.nix
    ./jellyfin.nix
    ./traefik
    ./docker-test.nix
  ];
}
