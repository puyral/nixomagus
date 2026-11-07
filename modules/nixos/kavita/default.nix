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
        # Host ssh key, used by sops-nix inside the container to decrypt secrets
        "/etc/sops" = {
          hostPath = "/etc/ssh/ssh_host_ed25519_key";
          isReadOnly = true;
        };
      };
      autoStart = true;
      ephemeral = true;

      config =
        { config, ... }:
        {

          # sops inside the container, decrypting with the host ssh key mounted at /etc/sops
          sops.age.sshKeyPaths = [ "/etc/sops" ];
          sops.secrets.kavita_token = {
            sopsFile = ./token.sops-secret.yaml;
            key = "token";
          };

          services.kavita = {
            enable = true;
            dataDir = "/data";
            tokenKeyFile = config.sops.secrets.kavita_token.path;
            settings = {
              Port = port;

            };
          };

        };
    };
    extra.containers.${name} = {
      vpn = false;

      nginx = [
        {
          inherit port;
          enable = true;
          gzip-bomb.enable = true;
        }
      ];
    };
  };
}
