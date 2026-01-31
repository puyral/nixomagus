{ config, lib, ... }:
let
  cfg = config.extra.acme;
  domain = cfg.domain;
in
{
  imports = [ ./options.nix ];

  config = lib.mkIf cfg.enable {
    sops.secrets.ovh-acme = {
      sopsFile = ./ovh.sops-secret.env;
      format = "dotenv";
      owner = "acme";
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = (import (../../.. + "/secrets/email.nix")).gmail "acme";

      certs."${domain}" = {
        domain = domain;
        extraDomainNames = [ "*.${domain}" ];
        dnsProvider = "ovh";
        credentialsFile = config.sops.secrets.ovh-acme.path;
        group = "acme";
      };
    };
  };
}
