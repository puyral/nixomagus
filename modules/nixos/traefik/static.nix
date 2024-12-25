{
  rootDir,
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  staging = true;
  cfg = config.networking.traefik;
in
{
  config = {
    services.traefik.staticConfigOptions = mkIf cfg.enable {
      api = {
        dashboard = true;
        # insecure = true;
        debug = true;
      };
      entryPoints = {
        http = {
          address = ":80";
          http.redirections.entrypoint = {
            to = "https";
            scheme = "https";
          };
        };
        https = {
          address = ":443";
          http.tls = {
            certResolver = "ovh";
            domains = rec {
              main = config.networking.traefik.baseDomain;
              sans = [ "*.${main}" ];
            };
          };
        };
      };

      certificatesResolvers.ovh.acme = {
        email = (import (rootDir + /secrets/email.nix)).gmail "acme";
        storage = config.services.traefik.dataDir + "/acme.json";
        dnsChallenge.provider = "ovh";
        caServer =
          if staging then
            "https://acme-staging-v02.api.letsencrypt.org/directory"
          else
            "https://acme-v02.api.letsencrypt.org/directory";
      };

      log.level = config.networking.traefik.log.level;
    };
    networking.firewall = mkIf cfg.enable {
      allowedTCPPorts = [
        8080
        443
        80
      ];
      allowedUDPPorts = [
        8080
        80
      ];
    };
  };
}
