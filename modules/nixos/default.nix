{ lib, ... }:
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
    ./smartd
    ./headscale
  ];

  options = with lib; {
    params = {
      locations = {
        containers = mkOption {
          type = types.path;
          default = "/containers";
          description = "where to put all the containers by default";
        };
      };
    };
    vars = mkOption {
      type = types.attrs;
      default = { };
    };
  };
}
