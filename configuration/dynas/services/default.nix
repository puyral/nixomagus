{ pkgs, config, ... }:
{
  imports = [
    ./nfs.nix
    ./samba.nix
    ./cockpit.nix
    ./syncthing.nix
    # ./whatchtower.nix
    ./jellyfin.nix
    # ./traefik
    ./homeassistant
    # ./docker-test.nix
    ./portainer.nix
    ./mosquitto.nix
    ./zigbee2mqtt.nix
    ./photos
  ];

  services.watchtower.enable = true;

  networking = {
    nat = {
      enable = true;
      externalInterface = "enp9s0";
    };
    traefik = {
      enable = true;
      baseDomain = "puyral.fr";
      docker.enable = true;
    };
  };
}
