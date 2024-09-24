{ lib, config, ... }:
with lib;
let
  cfg = config.networking.traefik;
in
{
  inputs = [
    ./static.nix
    ./dynamic
  ];

  config = mkIf cfg.enable {
    users.groups.traefik = {
      members = [ "root" ];
    };
    users.users.traefik = {
      extraGroups = [
        "traefik"
        "docker"
      ];
    };
    services.traefik = {
      enable = true;
      dataDir = "/containers/traefik";
      group = "traefik";
      environmentFiles = [ ./secrets/ovh.env ];
    };

  };
}
