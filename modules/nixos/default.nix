{ ... }:
{
  imports = [
    # ./isw
    ./traefik
    ./wachtower
    ./docker-traefik
    ./containers
    ./zigbee2mqtt
    ./paperless
    ./usersNgroups.nix
    ./torrent
    ./mail
    ./refind
  ];
}
