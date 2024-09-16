{ rootDir, ... }:
let
  staging = true;
in
{
  services.traefik.staticConfigOptions = {
    api = {
      dashboard = true;
      insecure = true;
    };
    entryPoints = {
      http = {
        address = ":80";
      };
      https = {
        address = ":443";
      };
      web = {
        address = ":8080";
      };
    };

    certificatesResolvers.ovh.acme = {
      email = (import (rootDir + /secrets/email.nix)).gmail "acme";
      storage = "acme.json";
      dnsChallenge.provider = "ovh";
      caServer =
        if staging then
          "https://acme-staging-v02.api.letsencrypt.org/directory"
        else
          "https://acme-v02.api.letsencrypt.org/directory";
    };
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
}
