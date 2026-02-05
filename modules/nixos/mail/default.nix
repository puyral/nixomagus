{
  pkgs,
  lib,
  config,
  ...
}:
let

  name = config.networking.hostName;
  cfg = config.extra.mail;
  passwdFile = config.sops.secrets."mail-passwd-plain/root".path;
in
with lib;
{
  options.extra.mail.enable = mkEnableOption "sendmail";

  config = mkIf cfg.enable {

    sops.secrets."mail-passwd-plain/root" = {
      sopsFile = ../mail-server/passwords.sops-secret.json;
      format = "json";
      key = "root-plain";
      mode = "0444";
    };

    programs.msmtp = {
      enable = true;
      accounts.default = {
        tls = true;
        tls_starttls = false;
        auth = true;
        host = "mail.puyral.fr";
        port = 465;
        from = "${name}@puyral.fr";
        # from = "root@puyral.fr";
        passwordeval = "${pkgs.coreutils}/bin/cat ${passwdFile}";
        user = "root@puyral.fr";
      };
    };
  };
}
