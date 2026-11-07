# requires the module to work
# authentik-nix = {
#   url = "github:nix-community/authentik-nix";
#   inputs = {
#     nixpkgs.follows = "nixpkgs-unstable";
#   };
# };

attrs@{
  rootDir,
  authentik-nix ? null,
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
    assertions = [
      {
        assertion = false;
        message = "athentik doesn't work";
      }
    ];
    containers.${name} = {
      bindMounts =
        let
          mk = name: {
            name = "/var/lib/${name}";
            value = {
              hostPath = "${cfg.dataDir}/${name}";
              isReadOnly = false;
            };
          };
          # Host ssh key, used by sops-nix inside the container to decrypt secrets
          hostKey = {
            name = "/etc/sops";
            value = {
              hostPath = "/etc/ssh/ssh_host_ed25519_key";
              isReadOnly = true;
            };
          };
        in
        with builtins;
        listToAttrs (
          [ hostKey ]
          ++ map mk [
            "authentik"
            "postgres"
            "redis"
          ]
        );

      config =
        { config, ... }:
        {
          imports = [ authentik-nix.nixosModules.default ];

          # sops inside the container, decrypting with the host ssh key mounted at /etc/sops
          sops.age.sshKeyPaths = [ "/etc/sops" ];
          sops.secrets."authentik/env" = {
            sopsFile = ./authentik.sops-secret.env;
            format = "dotenv";
            key = ""; # whole file
          };

          services.authentik = {
            enable = true;
            environmentFile = config.sops.secrets."authentik/env".path;
            settings = {
              email = (import ./email.nix) attrs;
            };
          };
        };
    };

    extra.containers.${name} =
      let
        domain = "${cfg.extraDomain}.${config.networking.nginx.baseDomain}";
        regexpRule = "{subdomain:[a-z0-9]+}.${config.networking.nginx.baseDomain}";
      in
      {
        nginx = [
          {
            port = httpPort;
            enable = true;
            providers = [ config.vars.gatewayMachine ];
            # For now just using Host, the PathPrefix and RegexpRule need more complex Nginx config if actually used.
            # extra.rule = "Host(`${domain}`) || HostRegexp(`${regexpRule}`) && PathPrefix(`/outpost.goauthentik.io/`)";
          }
        ];
      };
    # networking.nginx.dynamicConfigOptions ... (middleware needs translation if used)
    # services.traefik = {
    #   dynamicConfigOptions = {
    #     http = {
    #       middlewares = {
    #         authentik = {
    #           forwardAuth = {
    #             tls.insecureSkipVerify = true;
    #             address = "https://${address}:${builtins.toString httpsPort}/outpost.goauthentik.io/auth/traefik";
    #             trustForwardHeader = true;
    #             authResponseHeaders = [
    #               "X-authentik-username"
    #               "X-authentik-groups"
    #               "X-authentik-email"
    #               "X-authentik-name"
    #               "X-authentik-uid"
    #               "X-authentik-jwt"
    #               "X-authentik-meta-jwks"
    #               "X-authentik-meta-outpost"
    #               "X-authentik-meta-provider"
    #               "X-authentik-meta-app"
    #               "X-authentik-meta-version"
    #             ];
    #           };
    #         };
    #       };
    #     };
    #   };
    # };
  };

}
