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
    sops.secrets.ovh = {
      sopsFile = ./secrets-sops/ovh.env;
      owner = "traefik";
      format = "dotenv";
    };
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
      environmentFiles = [ config.sops.secrets.ovh.path ];
    };

  };
}
