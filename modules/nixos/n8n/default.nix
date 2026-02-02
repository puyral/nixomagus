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
  dataDir = "/var/lib/n8n";
in
{
  imports = [ ./options.nix ];
  config = lib.mkIf cfg.enable {
    extra.containers.n8n = {
      gpu = true;
      traefik = [
        {
          inherit port;
          name = cfg.subdomain;
          enable = true;
          providers = cfg.providers;
        }
      ];
    };

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
        { ... }:
        {
          services.n8n = {
            enable = true;
            openFirewall = true;
          };

          systemd.services.n8n.environment = {
            N8N_USER_FOLDER = dataDir; 
            N8N_HOST = "0.0.0.0";
            N8N_PORT = toString port;
            WEBHOOK_URL = "https://${cfg.subdomain}.${hostConfig.extra.acme.domain}/";
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
  };
}
