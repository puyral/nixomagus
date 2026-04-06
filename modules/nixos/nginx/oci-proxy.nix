{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.virtualisation.oci-containers.proxy;

  # Filter enabled containers
  activeContainers = filterAttrs (n: v: v.enable) cfg.containers;
  sortedNames = sort (a: b: a < b) (attrNames activeContainers);

  # Assign a static IP based on alphabetical order to ensure stability
  # Starting from 172.20.0.10
  getIp =
    name:
    let
      idx = (
        let
          findIdx = n: l: if (head l) == n then 0 else 1 + (findIdx n (tail l));
        in
        findIdx name sortedNames
      );
    in
    "172.20.0.${toString (idx + 10)}";

  containerOptions = {
    options = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "nginx proxy for this container";
      };
      port = mkOption {
        type = types.port;
        description = "the internal port of the container";
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
  extraConfig = mkOption {
    type = types.lines;
    default = "";
    description = "extra configuration for this virtual host";
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

  config = mkIf (activeContainers != { }) {
    # Ensure the proxy network exists
    systemd.services.docker-network-proxy = {
      description = "Create Docker network for proxy";
      after = [
        "network.target"
        "docker.service"
      ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        check=$(${pkgs.docker}/bin/docker network ls -q -f name=^proxy$)
        if [ -z "$check" ]; then
          ${pkgs.docker}/bin/docker network create --subnet=172.20.0.0/16 proxy
        fi
      '';
    };

    # Configure the actual containers to use the proxy network and a static IP
    virtualisation.oci-containers.containers = mapAttrs (n: v: {
      extraOptions = [
        "--network=proxy"
        "--ip=${getIp n}"
      ];
    }) activeContainers;

    # Configure Nginx to point to the static IPs
    networking.nginx.instances = listToAttrs (
      mapAttrsToList (n: v: {
        name = if v.name != null then v.name else n;
        value = {
          inherit (v) enable port domain extraConfig;
          address = getIp n;
        };
      }) activeContainers
    );
  };
}
