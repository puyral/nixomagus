{ lib, config, ... }:
with lib;
let
  cfg = config.networking.traefik;
in
{
  imports = [
    ./static.nix
    ./dynamic
  ];

  config = {
    users.groups.traefik = mkIf cfg.enable { members = [ "root" ]; };
    users.users.traefik = mkIf cfg.enable {
      extraGroups = [
        "traefik"
        "docker"
      ];
    };
    services.traefik = mkIf cfg.enable {
      enable = true;
      dataDir = "${config.params.locations.containers}/traefik";
      group = "traefik";
      environmentFiles = [ ./secrets/ovh.env ];
    };

  };
}
