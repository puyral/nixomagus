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

  config = mkIf cfg.enable {
    sops.secrets.ovh = {
      sopsFile = ./secrets-sops/ovh.env;
      owner = "traefik";
      format = "dotenv";
    };
    users.groups.traefik =  { members = [ "root" ]; };
    users.users.traefik = {
      extraGroups = [
        "traefik"
        "docker"
      ];
    };
    services.traefik = {
      enable = true;
      dataDir = "${config.params.locations.containers}/traefik";
      group = "traefik";
      environmentFiles = [ config.sops.secrets.ovh.path ];
    };

  };
}
