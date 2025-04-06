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
    ./splashscreen
    ./syncthing-module
    ./calibre-web
    ./monitoring
    ./cachefilesd
    ./printing
    ./keyboard
    ./v4l2loopback
    ./github-runner
    ./binary-cache
    ./immich
    ./virtualisation
    ./controllers
    ./photoprism
    ./generate-jpgs
  ];
}
