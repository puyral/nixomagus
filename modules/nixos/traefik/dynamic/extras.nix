{ lib, config, ... }:
with lib;
let
  cfg = config.networking.traefik;

  name = config.networking.hostName;
  instances = lib.filterAttrs (
    _: { enable, providers, ... }: enable && (builtins.elem name providers)
  ) cfg.instances;
  entrypoints = "https";
  tls = {
    certResolver = "ovh";
  };
in
{
  config.vars.traefik = {
    inherit entrypoints tls;
  };
  config.services.traefik.dynamicConfigOptions.http =
    if instances == { } then
      { }
    else
      {
        routers = mapAttrs (
          host: attrs:
          let
            enable = attrs.enable;
            domain = if attrs.domain == null then cfg.baseDomain else attrs.domain;
            rule = if attrs.extra.rule == null then "Host(`${host}.${domain}`)" else attrs.extra.rule;
          in
          {
            inherit rule entrypoints tls;
            # entrypoints = "https";
            # tls.certResolver = "ovh";
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
                      if (attrs ? container && attrs.container != null) then
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
