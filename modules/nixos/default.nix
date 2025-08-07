{ lib, ... }:
let
  eimports = [
    ./tailscale
    # ./isw
  ];
in
{
  imports = [
    ((import ./containers) eimports)
    ./binary-cache
    ./traefik
    ./wachtower
    ./docker-traefik
    ./zigbee2mqtt
    ./paperless
    ./usersNgroups.nix
    ./torrent
    ./mail
    ./refind
    ./splashscreen
    ./syncthing-module
    ./calibre-web
    ./cachefilesd
    ./printing
    ./v4l2loopback
    ./github-runner
    ./immich
    ./virtualisation
    ./monitoring
    ./controllers
    ./photoprism
    ./smartd
    ./headscale
    ./authentik
    ./authelia
    ./tailscale-exit-container
    ./sops
    ./gui
    ./llm
    # ./keyboard
  ]
  ++ eimports;

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
