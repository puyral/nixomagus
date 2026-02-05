{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.extra.n8n;
  hostConfig = config;
  port = 5678;
  dataDir = config.services.n8n.environment.N8N_USER_FOLDER;
in
{
  imports = [ ./options.nix ];
  config = lib.mkIf cfg.enable {

    containers.n8n = {
      bindMounts = {
        "${dataDir}" = {
          hostPath = cfg.dataDir;
          isReadOnly = false;
        };
      };
      autoStart = true;
      ephemeral = true;
      config =
        { lib, config, ... }:
        {
          assertions = [
            {
              assertion = (dataDir == config.services.n8n.environment.N8N_USER_FOLDER);
              message = "mismatch between inside and outside container!";
            }
          ];
          services.n8n = {
            enable = true;
            openFirewall = true;
            # this option does not exists
            # package = pkgs-unstable.n8n;
            environment = {
              N8N_HOST = "0.0.0.0";
              N8N_PORT = toString port;
              WEBHOOK_URL = "https://${cfg.subdomain}.${hostConfig.extra.acme.domain}/";
            };
          };

          users.users.n8n = {
            group = "n8n";
            isSystemUser = true;
            # uid = 911;
          };
          users.groups.n8n = {
            # gid = 911;
          };

          systemd.services.n8n = {
            serviceConfig = {
              DynamicUser = lib.mkForce false;
              User = "n8n";
              Group = "n8n";
            };
          };

          hardware.graphics = {
            enable = true;
            extraPackages = with pkgs; [
              intel-media-driver
              intel-compute-runtime
            ];
          };
        };
    };

    extra.containers.n8n = {
      gpu = true;
      traefik = [
        {
          inherit port;
          name = cfg.subdomain;
          enable = true;
        }
      ];
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 root root -"
    ];
  };
}
