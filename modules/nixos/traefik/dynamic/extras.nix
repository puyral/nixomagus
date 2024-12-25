{ lib, config, ... }:
with lib;
let
  cfg = config.networking.traefik;

  name = config.networking.hostName;
  instances = lib.filterAttrs (name: {providers, ...}: builtins.elem name providers) cfg.instances
in
{
  services.traefik.dynamicConfigOptions.http = {
    routers = mapAttrs (
      host: attrs:
      let
        enable = attrs.enable;
        domain = if attrs.domain == null then cfg.baseDomain else attrs.domain;
      in
      mkIf enable {
        rule = "Host(`${host}.${domain}`)";
        entrypoints = "https";
        tls.certResolver = "ovh";
        service = host;
      }
    ) instances;
    services = mapAttrs (
      host:
      attrs@{ enable, port, ... }:
      mkIf enable {
        loadBalancer.servers =
          let
            host =
              if (attrs.container != null) then
                config.containers.${attrs.container}.localAddress
              else
                "localhost";
          in
          [ { url = "http://${host}:${builtins.toString port}"; } ];
      }
    ) instances;
  };
}
