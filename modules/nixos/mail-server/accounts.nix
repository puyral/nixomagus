{ config, ... }:
let
  cfg = config.extra.mail-server;
  domain = cfg.domain;
in
{
  sops.secrets.mail-passwd = {
    sopsFile = ./passwords.sops-secret.json;
    format = "json";
    key = "simon";
  };

  mailserver = {

    # A list of all login accounts. To create the password hashes, use
    # nix-shell -p mkpasswd --run 'mkpasswd -s'
    loginAccounts = {
      "simon@${domain}" = {
        hashedPasswordFile = config.sops.secrets.mail-passwd.path;
        aliases = [
          "security@${domain}"
          "smartd@${domain}"
          "github@${domain}"
          "simon.jeanteur@${domain}"
        ];
      };
    };
  };

}
