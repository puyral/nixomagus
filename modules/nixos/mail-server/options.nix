{ lib, config, ... }:
let
  cfg = config.extra.mail-server;
in
{
  options.extra.mail-server = with lib; {
    enable = mkEnableOption "mail-server";
    domains = mkOption {
      type = types.listOf types.str;
      default = [ "puyral.fr" ];
      description = "the domain for the email addresses";
    };
    mainDomain = mkOption {
      type = types.str;
      default = "${builtins.elemAt cfg.domains 0}";
    };
    fqdn = mkOption {
      type = types.str;
      default = "mail.${cfg.mainDomain}";
    };
    sopsKey = mkOption {
      type = types.externalPath;
    };

    dirs = {
      acme = mkOption {
        type = types.externalPath;
        default = "${config.security.acme.certs."${cfg.mainDomain}".directory}";
      };
      data = mkOption {
        type = types.externalPath;
        default = "${config.params.locations.containers}/mail-server";
      };
      mails = mkOption {
        type = types.pathWith { absolute = false; };
        default = "mails";
      };
    };

    remoteStorage = {
      enable = mkEnableOption "remote storage for emails";
      local = mkOption {
        type = types.path;
      };
    };
  };
}
