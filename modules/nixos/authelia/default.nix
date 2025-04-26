{ config, lib, ... }:
let
  cfg = config.extra.authelia;
  name = "authelia";
  url = "${cfg.extraDomain}.${domain}";
  domain = config.networking.traefik.baseDomain;
  instanceName = "main";
  port = 9091;
  address = config.containers.${name}.localAddress;

  hscfg = config.extra.headscale;
  attrs = {
    inherit
      name
      url
      domain
      instanceName
      port
      address
      cfg
      hscfg
      ;
  };
in
{
  options.extra.authelia = with lib; {
    enable = mkEnableOption "authelia";
    dataDir = mkOption {
      type = types.path;
      default = "${config.params.locations.containers}/${name}";
    };
    extraDomain = mkOption {
      type = types.str;
      default = name;
    };
    oidc.secrets = mkOption {
      type = types.attrs;
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    extra.authelia.oidc.secrets = lib.mkIf hscfg.enable (import ./secrets/oidc.nix);

    containers.${name} = {
      autoStart = true;
      ephemeral = true;
      bindMounts = {
        "/var/lib/authelia-${instanceName}" = {
          hostPath = "${cfg.dataDir}/${name}/${instanceName}";
          isReadOnly = false;
        };
      };

      config =
        { config, ... }:
        {

          imports = [
            ./authelia.nix
          ];

          options.vars = lib.mkOption {
            type = lib.types.attrs;
          };

          config.vars = attrs;
          config.services.redis.servers."authelia-${instanceName}" = {
            enable = true;
            user = config.services.authelia.instances.${instanceName}.user;
            port = 0;
            unixSocket = "/run/redis-authelia-${instanceName}/redis.sock";
            unixSocketPerm = 600;
          };
        };
    };
    extra.containers.${name} = {
      traefik = [
        {
          inherit port;
          enable = true;
          providers = [ "ovh-pl" ];
        }
      ];
    };
    services.traefik = {
      dynamicConfigOptions = {
        http = {
          middlewares = {
            authentik = {
              forwardAuth = {
                tls.insecureSkipVerify = true;
                address = "http://${address}:${builtins.toString port}/api/authz/forward-auth";
                trustForwardHeader = true;
                authResponseHeaders = [
                  "Remote-User"
                  "Remote-Groups"
                  "Remote-Email"
                  "Remote-Name"
                ];
              };
            };
          };
        };
      };
    };

  };
}
