{
  pkgs,
  lib,
  config,
  ...
}:
let

  name = config.networking.hostName;
  cfg = config.extra.mail;
  passwdFile = config.sops.secrets."mail-passwd-plain/${name}".path;
in
with lib;
{
  options.extra.mail.enable = mkEnableOption "sendmail";

  config = mkIf cfg.enable {

    sops.secrets."mail-passwd-plain/${name}" = {
      sopsFile = ../mail-server/passwords.sops-secret.json;
      format = "json";
      key = "root-plain";
    };

    programs.msmtp = {
      enable = true;
      accounts.default = {
        tls = true;
        auth = true;
        host = "mail.puyral.fr";
        port = 587;
        from = "${name}@puyral.fr";
        passwordeval = "${pkgs.coreutils}/bin/cat ${passwdFile}";
        user = "root@puyral.fr";
      };
    };
  };
}
