{ config, lib, ... }:
with builtins;
with lib;
let

  defaultBackend = options.virtualisation.oci-containers.backend.default;
  containerOptions =
    { ... }:
    {
      options = {
          port = mkOption {
            type = types.nullOr types.port;
            # default = null;
          };
          name = mkOption {
            type = types.nullOr types.str;
            default = null;
          };
      };
    };

  cfg = {
    traefik = config.networking.traefik.docker;
    # container = name: options.virtualisation.oci-containers.containers.${name}.proxy;
    # enabled = name: options.virtualisation.oci-containers.containers.${name}.proxy == { };
  };

  enabled = config.networking.traefik.enable && config.networking.traefik.docker.enable;
  containers = config.virtualisation.oci-containers.proxy.containers;
in
{
  options.virtualisation.oci-containers.proxy.containers = mkOption {
    type = types.attrsOf (types.submodule containerOptions);
    default = {};
  };
  config = {
    virtualisation.oci-containers.containers = 
      let
        f =
          n: value:
          let
            # nvalue = removeAttrs "proxy" value;
            name = value.name;
            port = value.port;

            labels = mkIf enabled {
              "traefik.enable" = "true";
              "traefik.http.routers.${name}.rule" = "Host(`${name}.${config.network.traefik.baseDomain}`)";
              "traefik.http.routers.${name}.entrypoints" = "https";
              "traefik.http.routers.${name}.tls.certresolver" = "ovh";
              "traefik.http.services.${name}.loadbalancer.server." = toString port;
            };
          in
          # recursiveUpdate nvalue { inherit labels; };
          {
            inherit labels;
          };
      in
      mapAttrs f containers;

    systemd.services = mkIf enabled (
      mapAttrs' (n: v: {
        name = "${config.virtualisation.oci-containers.backend}-${n}";
        value = {
          after = [ "${cfg.traefik.serviceName}.service" ];
          requires = [ "${cfg.traefik.serviceName}.service" ];
          wantedBy = [ "multi-user.target" ];
        };
      }) containers
    );
  };

}
