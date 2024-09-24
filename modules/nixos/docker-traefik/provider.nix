{ config, lib, ... }:
with lib builtins;

let
  cfg = config.networking.traefik.docker;
in

{
  options = {
    networking.traefik.docker = {
      enable = mkEnableOption "docker provider for traefik";
      network = {

        name = mkOption {
          default = "traefik";
          type = types.str;
          description = "the name of the network to use for traefik";
        };
        gateway = mkOption {
          type = types.str;
          default = "172.16.0.1";
          description = "the gateway use for the traefik docker network";
        } a;
        subnetSize = mkOption {
          type = type.int.u8;
          default = 16;
          description = "the size of the subnet. The final subnet is decided using the gateway's ip";
        };

      };

      serviceName = mkOption {
        default = "traefik-network";
        type = types.str;
        description = "the name of the service spawning the docker networks";
      };
      targetName = mkOption {
        default = "traefik-root";
        type = types.str;
        description = "the name of the systemd target for the docker networks";
      };

      socket = mkOption {
        type = types.path;
        default = "/var/run/traefik-docker.sock";
      };
    };
  };

  # enable the docker provider for traefik
  config = mkIf (config.networking.traefik.enable && cfg.enable) {

    virtualisation.docker = {
      enable = true;
      listenOptions = [
        toString
        cfg.socket
      ];
    };
    virtualisation.oci-containers.backend = "docker";

    services.traefik.staticConfigOptions = {
      providers.docker = {
        watch = true;
        exposedByDefault = false;
        endpoint = "unix://${cfg.socket}";
        network = "traefik";
      };
    };

    systemd.services.traefik = {
      after = [ "${cfg.serviceName}.service" ];
      requires = [ "${cfg.serviceName}.service" ];
      partOf = [ "${cfg.targetName}.target" ];
      wantedBy = [ "${cfg.targetName}.target" ];
    };

    # network for docker
    systemd.services.${cfg.serviceName} =
      let
        netName = cfg.network.name;
      in
      {
        path = [ config.virtualisation.docker.package ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStop = "docker network rm -f ${netName}";
        };
        script = ''
          docker network inspect ${netName} || docker network create ${netName} --subnet "${cfg.network.gateway}/${toString cfg.network.subnetSize}" --gateway "${cfg.network.gateway}"
        '';
        partOf = [ "${cfg.targetName}.target" ];
        wantedBy = [ "${cfg.targetName}.target" ];
      };

    systemd.targets.${cfg.targetName} = {
      unitConfig = {
        Description = "Traefik root";
      };
    };
  };
}
