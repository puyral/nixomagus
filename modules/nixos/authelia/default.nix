{ config, lib, ... }:
let
  cfg = config.extra.authelia;
  name = "authelia";
  url = "${cfg.extraDomain}.${domain}";
  domain = config.networking.traefik.baseDomain;
  instanceName = "main";
  port = 9091;
  address = config.containers.${name}.localAddress;

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
  };

  config = lib.mkIf cfg.enable {

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
          services.authelia.instances.${instanceName} = {
            enable = true;
            secrets = import ./secrets/secrets.nix;
            settings = {
              default_redirection_url = "https://${url}";
              server = {
                host = "0.0.0.0";
                inherit port;
              };

              log = {
                level = "debug";
                format = "text";
              };

              authentication_backend = {
                file = {
                  path = "/var/lib/authelia-${instanceName}/users_database.yml";
                  watch = true;
                  search = {
                    email = true;
                  };
                };
              };

              access_control = {
                default_policy = "deny";
                rules = [
                  {
                    domain = [ "${name}.${domain}" ];
                    policy = "bypass";
                  }
                  {
                    domain = [ "*.${domain}" ];
                    policy = "one_factor";
                  }
                ];
              };

              session = {
                inherit domain;
                name = "authelia_session";
                expiration = "12h";
                inactivity = "45m";
                remember_me_duration = "1M";
                redis.host = config.services.redis.servers."authelia-${instanceName}".unixSocket;
              };

              regulation = {
                max_retries = 3;
                find_time = "5m";
                ban_time = "15m";
              };

              storage = {
                local = {
                  path = "/var/lib/authelia-${instanceName}/db.sqlite3";
                };
              };

              notifier = {
                disable_startup_check = false;
                filesystem = {
                  filename = "/var/lib/authelia-${instanceName}/notification.txt";
                };
              };
            };
          };

          services.redis.servers."authelia-${instanceName}" = {
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
