attrs@{ config, ... }:
{

  imports = [
    ./headscale.nix
  ];

  # sops inside the container, decrypting with the host ssh key mounted at /etc/sops
  sops.age.sshKeyPaths = [ "/etc/sops" ];
  sops.secrets =
    let
      sopsFile = ./secrets.sops-secret.yaml;
    in
    {
      "authelia/jwt" = {
        inherit sopsFile;
        key = "jwt";
      };
      "authelia/storage-encryption-key" = {
        inherit sopsFile;
        key = "storage_encryption_key";
      };
      "authelia/session-secret" = {
        inherit sopsFile;
        key = "session_secret";
      };
      "authelia/oidc-hmac-secret" = {
        inherit sopsFile;
        key = "oidc_hmac_secret";
      };
      "authelia/oidc-issuer-private-key" = {
        inherit sopsFile;
        key = "oidc_issuer_private_key";
      };
      "authelia/smtp-password" = {
        inherit sopsFile;
        key = "smtp_password";
      };
    };

  services.authelia.instances.${config.vars.instanceName} = with config.vars; {
    enable = true;
    secrets = {
      jwtSecretFile = config.sops.secrets."authelia/jwt".path;
      storageEncryptionKeyFile = config.sops.secrets."authelia/storage-encryption-key".path;
      sessionSecretFile = config.sops.secrets."authelia/session-secret".path;
      oidcHmacSecretFile = config.sops.secrets."authelia/oidc-hmac-secret".path;
      oidcIssuerPrivateKeyFile = config.sops.secrets."authelia/oidc-issuer-private-key".path;
    };
    environmentVariables = {
      AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE = config.sops.secrets."authelia/smtp-password".path;
    };
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
        smtp = {
          address = "submission://smtp.gmail.com:587";
          username = "simon.jeanteur";
          sender = "simon.jeanteur+authelia@gmail.com";
          # password provided at runtime via AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE
          startup_check_address = "github@puyral.fr";
        };
      };

    };
  };
}
