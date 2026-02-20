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
        routers =
          let
            mkRouter =
              host: attrs:
              let
                domain = if attrs.domain == null then cfg.baseDomain else attrs.domain;
                rule = if attrs.extra.rule == null then "Host(`${host}.${domain}`)" else attrs.extra.rule;
              in
              {
                "${host}" = {
                  inherit rule tls;
                  entryPoints = [ "https" ];
                  service = host;
                };
                "${host}-insecure" =
                  if attrs.forceHttps then
                    {
                      inherit rule;
                      entryPoints = [ "http" ];
                      middlewares = [ "redirect-to-https" ];
                      service = host;
                    }
                  else
                    {
                      inherit rule;
                      entryPoints = [ "http" ];
                      service = host;
                    };
              };
          in
          foldl' (acc: x: acc // x) { } (mapAttrsToList mkRouter instances);

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
