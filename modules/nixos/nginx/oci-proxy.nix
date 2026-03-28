{ config, lib, ... }:
with lib;
let
  cfg = config.virtualisation.oci-containers.nginx;
  nginx_cfg = config.networking.nginx;

  containerOptions = {
    options = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "nginx proxy for this container";
      };
      port = mkOption {
        type = types.port;
        description = "the port to forward to";
      };
      name = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "the subdomain name (defaults to container name)";
      };
      domain = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "the domain (defaults to nginx.baseDomain)";
      };
      address = mkOption {
        type = types.nullOr types.str;
        default = "localhost";
        description = "the address to forward to";
      };
    };
  };
in
{
  options.virtualisation.oci-containers.proxy = {
    containers = mkOption {
      type = types.attrsOf (types.submodule containerOptions);
      default = { };
      description = "Proxy configurations for OCI containers";
    };
  };

  config.networking.nginx.instances = listToAttrs (mapAttrsToList (n: v: {
    name = if v.name != null then v.name else n;
    value = {
      enable = v.enable;
      port = v.port;
      domain = v.domain;
      address = v.address;
    };
  }) config.virtualisation.oci-containers.proxy.containers);
}
