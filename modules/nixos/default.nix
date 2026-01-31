{ lib, sops-nix, ... }:
let
  eimports = [
    ./tailscale
    sops-nix.nixosModules.sops
    ./sops
    # ./isw
  ];
in
{
  imports = [
    ((import ./containers) eimports)
    ../commun
    ./binary-cache
    ./traefik
    ./acme
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
    ./gui
    ./llm
    ./nix-ld
    ./kavita
    ./fileflows
    ./ntfy
    ./mail-server
    ./bitwarden
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
