attrs@{
  rootDir,
  authentik-nix,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.extra.authentik;
  name = "authentik";
  httpPort = 9000;
  httpsPort = 9443;
  address = config.containers.${name}.localAddress;
in
{
  options.extra.authentik = with lib; {
    enable = mkEnableOption "authentik";
    dataDir = mkOption {
      type = types.path;
      default = "${config.params.locations.containers}/authentik";
    };
    extraDomain = mkOption {
      type = types.str;
      default = "authentik";
    };
  };

  config = lib.mkIf cfg.enable {
    containers.${name} = {
      autoStart = true;
      ephemeral = true;
      bindMounts =
        let
          mk = name: {
            name = "/var/lib/${name}";
            value = {
              hostPath = "${cfg.dataDir}/${name}";
              isReadOnly = false;
            };
          };
          # {
          #   "/var/lib/authentik" = {
          #     hostPath = "${cfg.dataDir}/data";
          #     isReadOnly = false;
          #   };
          #   "/var/lib/postgres" = {
          #     hostPath = cfg.dataDir + /postgres;
          #     isReadOnly = false;
          #   };
          #   "/var/lib/redis" = {
          #     hostPath = cfg.dataDir + /redis;
          #     isReadOnly = false;
          #   };
          # };
        in
        with builtins;
        listToAttrs (
          map mk [
            "authentik"
            "postgres"
            "redis"
          ]
        );

      config =
        { ... }:
        {
          imports = [ authentik-nix.nixosModules.default ];

          services.authentik = {
            enable = true;
            environmentFile = pkgs.substituteAll {
              src = ./secrets/env.env;
              emailPwd = builtins.readFile (rootDir + /secrets/mail-passwd);
              httpPort = builtins.toString httpPort;
              httpsPort = builtins.toString httpsPort;
            };
            settings = {
              email = (import ./secrets/email.nix) attrs;
            };
          };
        };
    };

    extra.containers.${name} =
      let
        domain = "${cfg.extraDomain}.${config.networking.traefik.baseDomain}";
        regexpRule = "{subdomain:[a-z0-9]+}.${config.networking.traefik.baseDomain}";
      in
      {
        traefik = [
          {
            port = httpPort;
            enable = true;
            providers = [ "ovh-pl" ];
            extra.rule = "Host(`${domain}`) || HostRegexp(`${regexpRule}`) && PathPrefix(`/outpost.goauthentik.io/`)";
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
                address = "https://${address}:${builtins.toString httpsPort}/outpost.goauthentik.io/auth/traefik";
                trustForwardHeader = true;
                authResponseHeaders = [
                  "X-authentik-username"
                  "X-authentik-groups"
                  "X-authentik-email"
                  "X-authentik-name"
                  "X-authentik-uid"
                  "X-authentik-jwt"
                  "X-authentik-meta-jwks"
                  "X-authentik-meta-outpost"
                  "X-authentik-meta-provider"
                  "X-authentik-meta-app"
                  "X-authentik-meta-version"
                ];
              };
            };
          };
        };
      };
    };
  };

}
