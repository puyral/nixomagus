{ lib, config, ... }:
with lib;
let
  cfg = config.networking.reverse_proxy;
in
{
  options.networking =
    let
      options = {
        domain = mkOption {
          default = "puyral.fr";
          type = types.str;
          description = "the base domain";
        };
        port = mkOption {
          type = types.port;
          description = "the port to forward to";
        };
        container = mkOption {
          type = types.nullOr types.str;
          description = "the container name, if it's in a nixos container";
          default = null;
        };
      };
    in
    {
      reverse_proxy = mkOption {
        default = { };
        type =
          with types;
          attrsOf (submodule {
            inherit options;
          });
      };
    };
  config.services.traefik.dynamicConfigOptions.http = {
    routers = mapAttrs (
      host:
      { domain, ... }:
      {
        rule = "Host(`${host}.${domain}`)";
        entrypoints = "https";
        tls.certResolver = "ovh";
        service = host;
      }
    ) cfg;
    services = mapAttrs (
      host:
      attrs@{ domain, port, ... }:
      {
        loadBalancer.servers =
          let
            host = if attrs ? container then config.containers.${attrs.container}.localAddress else "localhost";
          in
          [ { url = "http://${host}:${builtins.toString port}"; } ];
      }
    ) cfg;
  };
}
