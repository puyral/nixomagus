{
  config,
  lib,
  sops-nix,
  ...
}:
let
  cfg = config.extra.ntfy;
  dataDir = "/ntfy-sh";
in

{
  imports = [ ./options.nix ];
  config = lib.mkIf cfg.enable {

    sops.secrets.ntfy-secrets = {
      sopsFile = ./secrets.sops-secret.env;
      format = "dotenv";
    };

    containers.ntfy = {
      bindMounts = {
        "${dataDir}" = {
          hostPath = cfg.dataDir;
          isReadOnly = false;
        };
        "/secrets.env" = {
          hostPath = config.sops.secrets.ntfy-secrets.path;
        };
      };
      autoStart = true;
      ephemeral = true;

      config =
        { config, ... }:
        {
          # imports = [    sops-nix.nixosModules.sops];

          services.ntfy-sh = {
            enable = true;
            settings = {
              behind-proxy = true;
              base-url = "https://${cfg.url}.puyral.fr";
              cache-file = "${dataDir}/msg-cache.db";
              attachment-cache-dir = "${dataDir}/attachments";
              auth-file = "${dataDir}/user.db";
              auth-default-access = "deny-all";
              log-level = "trace";
              listen-http = "0.0.0.0:2586";
            };
            environmentFile = "/secrets.env";
          };
          systemd.services.ntfy-sh = {
            # serviceConfig.ReadWritePaths = dataDir;
            serviceConfig.DynamicUser = lib.mkForce false;
          };
        };
    };
    extra.containers.ntfy = {
      traefik = [
        {
          port = 2586;
          enable = true;
        }
      ];
    };
  };
}
