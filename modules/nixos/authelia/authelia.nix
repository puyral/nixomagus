attrs@{ config, ... }:
{

  imports = [
    ./headscale.nix
  ];

  services.authelia.instances.${config.vars.instanceName} = with config.vars; {
    enable = true;
    secrets = import ./secrets/secrets.nix;
    settings = {
      default_redirection_url = "https://${url}";
      theme = "auto";
      server.address = "0.0.0.0:${builtins.toString port}";
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
        expiration = "5h";
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
        # filesystem = {
        #   filename = "/var/lib/authelia-${instanceName}/notification.txt";
        # };
        smtp = (import ./secrets/email.nix) attrs;
      };

    };
  };
}
