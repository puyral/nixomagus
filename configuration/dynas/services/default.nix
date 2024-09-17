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
    ./homeassistant
    # ./docker-test.nix
    ./portainer.nix
    ./mosquitto.nix
    ./zigbee2mqtt.nix
    ./photos
  ];

  networking.nat.enable = true;
  networking.nat.externalInterface = "enp9s0";
}
