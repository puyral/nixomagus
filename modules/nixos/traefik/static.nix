{
  rootDir,
  config,
  lib,
  ...
}:
with lib builtins;
let
  staging = false;
  cfg = config.networking.traefik;
in
{
  config = mkIf cfg.enable {
    services.traefik.staticConfigOptions = {
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
            domains = {
              main = "puyral.fr";
              sans = [ "*.puyral.fr" ];
            };
          };
        };
        # web = {
        #   address = ":8080";
        # };
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

      log.level = "DEBUG";
    };
    networking.firewall = {
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
