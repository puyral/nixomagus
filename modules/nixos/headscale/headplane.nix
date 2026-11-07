{
  config,
  lib,
  pkgs,
  ...
}:
let
  oidc = config.vars.oidc;
  cfg = config.vars.cfg;
  port = cfg.headplane.port;
  cookieSecretFile = config.sops.secrets."headplane/cookie-secret".path;
  apiKeyFile = config.sops.secrets."headscale/api-key".path;
  clientSecretFile = config.sops.secrets."headplane/oidc-client-secret".path;
in
{
  # sops inside the container, decrypting with the host ssh key mounted at /etc/sops
  sops.age.sshKeyPaths = [ "/etc/sops" ];
  sops.secrets =
    let
      sopsFile = ./secrets.sops-secret.env;
    in
    {
      "headplane/cookie-secret" = {
        inherit sopsFile;
        format = "dotenv";
        key = "HEADPLANE_COOKIE_SECRET";
      };
      "headscale/api-key" = {
        inherit sopsFile;
        format = "dotenv";
        key = "HEADSCALE_API_KEY";
      };
      "headplane/oidc-client-secret" = {
        inherit sopsFile;
        format = "dotenv";
        key = "HEADPLANE_OIDC_CLIENT_SECRET";
      };
    };

  services.headplane = {
    enable = true;
    # agent.enable = false;
    # agent = {
    #   # As an example only.
    #   # Headplane Agent hasn't yet been ready at the moment of writing the doc.
    #   enable = false;
    #   settings = {
    #     HEADPLANE_AGENT_DEBUG = true;
    #     HEADPLANE_AGENT_HOSTNAME = "localhost";
    #     HEADPLANE_AGENT_TS_SERVER = "https://example.com";
    #     HEADPLANE_AGENT_TS_AUTHKEY = "xxxxxxxxxxxxxx";
    #     HEADPLANE_AGENT_HP_SERVER = "https://example.com/admin/dns";
    #     HEADPLANE_AGENT_HP_AUTHKEY = "xxxxxxxxxxxxxx";
    #   };
    # };
    settings = {
      server = {
        inherit port;
        host = "0.0.0.0";
        cookie_secret_path = cookieSecretFile;
        cookie_secure = true;
      };
      headscale = rec {
        url = "https://${cfg.extraDomain}.${config.vars.baseDomain}";
        public_url = url;
        config_strict = true;
        api_key_path = apiKeyFile;
      };

      # integration.proc.enabled = false;
      integration = {
        proc.enabled = true;
        agent = {
          enabled = false;
        };
      };
      oidc = lib.mkIf config.vars.authcfg.enable (
        let
          issuer = "https://${config.vars.authcfg.extraDomain}.${config.vars.baseDomain}";
        in
        {
          inherit issuer;
          client_id = oidc.headplane.id;
          client_secret_path = clientSecretFile;
          disable_api_key_login = true;
          # Might needed when integrating with Authelia.
          token_endpoint_auth_method = "client_secret_basic";
          # redirect_uri = "https://${cfg.extraDomain}.${config.vars.baseDomain}/admin/oidc/callback";
        }
      );
    };
  };
}
