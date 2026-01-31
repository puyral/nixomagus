{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.extra.bitwarden;
  name = "bitwarden";
  port = 80;
  dataDir = cfg.dataDir;
  StateDirectory =
    if lib.versionOlder config.system.stateVersion "24.11" then "bitwarden_rs" else "vaultwarden";
  innerDataDir = "/var/lib/${StateDirectory}";

  secretEnv = config.sops.secrets.bitwarden_env.path;
in
{
  options.extra.bitwarden = with lib; {
    enable = mkEnableOption name;
    dataDir = mkOption {
      type = types.path;
      default = "${config.params.locations.containers}/${name}";
    };
  };
  config = lib.mkIf cfg.enable {
    sops.secrets.bitwarden_env = {
      sopsFile = ./secrets.sops-secret.env;
    };

    containers.${name} = {
      bindMounts = {
        "${innerDataDir}" = {
          hostPath = dataDir;
          isReadOnly = false;
        };
        "${secretEnv}" = {
          hostPath = secretEnv;
          isReadOnly = true;
        };
      };
      autoStart = true;
      ephemeral = true;
      config =
        { config, ... }:
        {

          assertion = {
            config.systemd.services.vaultwarden.StateDirectory = StateDirectory;
          };

          services.vaultwarden = {
            enable = true;
            domain = "bitwarden.puyral.fr";
            environmentFile = secretEnv;
          };
        };
    };
    extra.containers.${name} = {
      traefik = [
        {
          inherit port;
          enable = true;
        }
      ];
    };
  };
}
