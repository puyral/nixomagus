{ config, lib, ... }:
let
  cfg = config.extra.mail-server;
  domain = cfg.mainDomain;
  accounts = config.mailserver.loginAccounts;
  hashPath = n: config.sops.secrets."mail-passwd/${n}".path;
in
{
  # imports = [ ./passwords.nix ];

  sops.secrets = lib.mapAttrs' (name: value: {
    name = "mail-passwd/${name}";
    value = {
      sopsFile = ./passwords.sops-secret.json;
      format = "json";
      key = name;
    };
  }) accounts;

  # sops.secrets.mail-passwd = {
  #   sopsFile = ./passwords.sops-secret.json;
  #   format = "json";
  #   key = "simon";
  # };

  mailserver = {

    # A list of all login accounts. To create the password hashes, use
    # nix-shell -p mkpasswd --run 'mkpasswd -s'
    loginAccounts = {
      "simon@${domain}" = {
        hashedPasswordFile = hashPath "simon@${domain}";
        aliases = [
          "security@${domain}"
          "smartd@${domain}"
          "github@${domain}"
          "simon.jeanteur@${domain}"
          "simon@${domain}"
        ];
      };
      "ai@${domain}" = {
        hashedPasswordFile = hashPath "ai@${domain}";
      };
      "n8n@${domain}" = {
        hashedPasswordFile = hashPath "n8n@${domain}";
      };
    };
  };

}
