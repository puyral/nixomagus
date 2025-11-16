
{
  config,
  pkgs-unstable,
  pkgs,
  lib,
  ...
}:
let
  port = 5000;
  gconfig = config;
  cfg = config.extra.kavita;
  name = "kavita";
in
{
  imports = [ ./options.nix ];
  config = lib.mkIf cfg.enable {
    networking.nat.internalInterfaces = [ "ve-${name}" ];
    containers.${name} = {
      bindMounts = {
        "/data" = {
          hostPath = cfg.dataDir;
          isReadOnly = false;
        };
        "/library" = {
          hostPath = cfg.library;
          isReadOnly = false;
        };
      };
      autoStart = true;
      ephemeral = true;

      config =
        { ... }:
        {

          services.kavita = {
            enable = true;
            dataDir = "/data";
            tokenKeyFile = ./secrets/token;
            settings = {
              Port = port;

            };
          };

          services.tailscale.enable = true;
        };
    };
    extra.containers.${name} = {
      vpn = true;

      traefik = [
        {
          inherit port;
          enable = true;
        }
      ];
    };
  };
}
