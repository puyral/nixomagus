{
  config,
  pkgs-unstable,
  pkgs,
  lib,
  ...
}:
let
  uiPort = 2283;
  gconfig = config;
  cfg = config.extra.forgejo;
in
{
  imports = [./options.nix];
  config = lib.mkIf cfg.enable {
    containers.forgejo = {
      bindMounts = {
        "/data" = {
          hostPath = cfg.dataDir;
          isReadOnly =  false;
        };
      };
      autoStart = true;
      ephemeral = true;

      config =
        { ... }:
        {
          services.forgejo = {
            enable = true;
            stateDir = "/data";
            settings = {
              # mailer = {
              #   ENABLED = true;
              #   PROTOCOL = "sendmail";
              #   FROM = "do-not-reply@example.org";
              #   SENDMAIL_PATH = "${pkgs.system-sendmail}/bin/sendmail";
              # };
              server = {
                HTTP_PORT = uiPort;
                SSH_PORT = cfg.sshPort;
              };
              service = {
                DISABLE_REGISTRATION = true;
              };
            };
            lfs = {
              enable = true;
            };
            dump = {
              enable = true;
            };
          };
        };
    };
    extra.containers.forgejo = {
      nginx = [
        {
          port = uiPort;
          name = cfg.subdomain;
          enable = true;
          providers = cfg.providers;
        }
      ];
    };
  };

}