{ config, lib, ... }:
let
  c = config.vars;
  default_policy = "deny";
  hsurl = "https://${c.hscfg.extraDomain}.${c.domain}";
  secrets = c.cfg.oidc.secrets;
in
{
  config.services.authelia.instances.${c.instanceName}.settings = lib.mkIf c.hscfg.enable {
    identity_providers = {
      oidc = {
        hmac_secret = secrets.hmac_secret;
        jwks = [
          {
            key = builtins.readFile ./secrets/private.pem;
          }
        ];
        # https://headscale.net/development/ref/oidc/#authelia
        claims_policies.default.id_token = [
          "groups"
          "email"
          "email_verified"
          "alt_emails"
          "preferred_username"
          "name"
        ];
        authorization_policies = {
          headplane = {
            inherit default_policy;
            rules = [
              {
                policy = "one_factor";
                subject = "group:admin";
              }
            ];
          };
          headscale = {
            inherit default_policy;
            rules = [
              {
                policy = "one_factor";
                subject = "group:headscale_user";
              }
            ];
          };
        };
        clients =
          let
            redirect_uris = [
              "${hsurl}/oidc/callback"
              "${hsurl}/admin/oidc/callback"
            ];
            scopes = [
              "openid"
              "profile"
              "email"
              "groups"
            ];
            public = false;
            userinfo_signed_response_alg = "none";

          in
          [
            {
              inherit
                redirect_uris
                scopes
                public
                userinfo_signed_response_alg
                ;
              client_id = secrets.headplane.id;
              client_name = "Headplane";
              authorization_policy = "headplane";
              client_secret = secrets.headplane.hashed;
              claims_policy = "default";
            }
            {
              inherit
                redirect_uris
                scopes
                public
                userinfo_signed_response_alg
                ;
              client_id = secrets.headscale.id;
              client_name = "Headscale";
              authorization_policy = "headscale";
              client_secret = secrets.headscale.hashed;
              claims_policy = "default";
            }
          ];
      };
    };
  };
}
