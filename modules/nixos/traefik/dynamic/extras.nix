{ lib, config, ... }:
with lib;
let
  cfg = config.networking.traefik;

  name = config.networking.hostName;
  instances = lib.filterAttrs (
    _: { enable, providers, ... }: enable && (builtins.elem name providers)
  ) cfg.instances;
in
{
  services.traefik.dynamicConfigOptions.http =
    if instances == { } then
      { }
    else
      {
        routers = mapAttrs (
          host: attrs:
          let
            enable = attrs.enable;
            domain = if attrs.domain == null then cfg.baseDomain else attrs.domain;
          in
          {
            rule = "Host(`${host}.${domain}`)";
            entrypoints = "https";
            tls.certResolver = "ovh";
            service = host;
          }
        ) instances;
        services = mapAttrs (
          host:
          attrs@{
            enable,
            port,
            address,
            ...
          }:
          {
            loadBalancer.servers =
              let
                host =
                  if address != null then
                    address
                  else
                    (
                      if (attrs ? containers && attrs.containers != null) then
                        config.containers.${attrs.container}.localAddress
                      else
                        "localhost"
                    );
              in
              [ { url = "http://${host}:${builtins.toString port}"; } ];
          }
        ) instances;
      };
}
