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
    extra.acme.enable = lib.mkDefault true;
    sops.secrets.ovh-acme = lib.mkDefault {
      sopsFile = ../acme/ovh.sops-secret.env;
      owner = "traefik";
      format = "dotenv";
    };
    users.groups.traefik = {
      members = [ "root" ];
    };
    users.users.traefik = {
      extraGroups = [
        "traefik"
        "docker"
        "acme"
      ];
    };
    services.traefik = {
      enable = true;
      dataDir = "${config.params.locations.containers}/traefik";
      group = "traefik";
      environmentFiles = [ config.sops.secrets.ovh-acme.path ];
    };

  };
}
