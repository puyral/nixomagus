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
        "/var/lib/n8n" = {
          hostPath = cfg.dataDir;
          isReadOnly = false;
        };
      };
      autoStart = true;
      ephemeral = true;
      config =
        { pkgs-unstable, ... }:
        {
          services.n8n = {
            enable = true;
            openFirewall = true;
            package = pkgs-unstable.n8n;
          };

          systemd.services.n8n.environment = {
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
