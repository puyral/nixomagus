{ config, lib, ... }:
let
  cfg = config.extra.mail-server;
  domain = cfg.domain;
in
{
  imports = [ ./options.nix ];

  # mostly pulled straight out of https://nixos-mailserver.readthedocs.io/en/latest/setup-guide.html

  config = lib.mkIf cfg.enable {
    sops.secrets.mail-passwd = {
      sopsFile = ./passwords.sops-secret.json;
      format = "json";
      key = "simon";
    };

    mailserver = {
      enable = true;
      stateVersion = 3;
      fqdn = "mail.${domain}";
      domains = [ domain ];

      certificateScheme = "acme";
      acmeCertificateName = domain;

      # A list of all login accounts. To create the password hashes, use
      # nix-shell -p mkpasswd --run 'mkpasswd -s'
      loginAccounts = {
        "simon@${domain}" = {
          hashedPasswordFile = config.sops.secrets.mail-passwd.path;
          aliases = [
            "postmaster@${domain}"
            "security@${domain}"
          ];
        };
      };
    };
  };
}
