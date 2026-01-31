{ config, lib, ... }:
let
  cfg = config.extra.mail-server;
  domain = cfg.domain;
in
{
  # mostly pulled straight out of https://nixos-mailserver.readthedocs.io/en/latest/setup-guide.html

  config = lib.mkIf cfg.enable {
    security.acme = {
      acceptTerms = true;
      defaults.email = "security@${domain}";
      certs.${config.mailserver.fqdn} = {
        # I'd like to reuse somwhat what I already have
        # see the traefik configuration

        # Further setup required, check the manual:
        # https://nixos.org/manual/nixos/stable/#module-security-acme
      };
    };

    sops.secrets.mail-passwd = {
      sopsFile = ./passwords.sops-secret.json;
      type = "json";
      key = "simon";
    };

    mailserver = {
      enable = true;
      stateVersion = 3;
      fqdn = "mail.${domain}";
      domains = [ domain ];

      # ???
      x509.useACMEHost = config.mailserver.fqdn;

      # A list of all login accounts. To create the password hashes, use
      # nix-shell -p mkpasswd --run 'mkpasswd -s'
      loginAccounts = {
        "simon@${domain}" = {
          hashedPasswordFile = config.sops.secrets.mail-passwd.path;
          aliases = [ "postmaster@${domain}" "security@${domain}" ];
        };
      };
    };
  };
}
