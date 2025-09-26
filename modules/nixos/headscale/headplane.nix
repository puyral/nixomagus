headplane:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  oidc = config.vars.oidc;
  cfg = config.vars.cfg;
  secrets = if cfg.secrets == null then (import ./secrets/default.nix) else cfg.secrets;
  port = cfg.headplane.port;
in
{
  imports = [
    headplane.nixosModules.headplane
    {
      nixpkgs.overlays = [ headplane.overlays.default ];
    }
  ];
  services.headplane = {
    enable = true;
    agent.enable = false;
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
        # cookie_secret_path = pkgs.writeText "smth_other" secrets.cookie_secret;
        cookie_secret = secrets.cookie_secret;
        cookie_secure = true;
      };
      headscale = rec {
        url = "https://${cfg.extraDomain}.${config.vars.baseDomain}";
        public_url = url;
        config_strict = true;
      };

      integration.proc.enabled = false;
      oidc = lib.mkIf config.vars.authcfg.enable (
        let
          issuer = "https://${config.vars.authcfg.extraDomain}.${config.vars.baseDomain}";
        in
        {
          inherit issuer;
          client_id = oidc.headplane.id;
          # client_secret_path = pkgs.writeText "smth" oidc.headplane.plain;
          client_secret = oidc.headplane.plain;
          disable_api_key_login = true;
          # Might needed when integrating with Authelia.
          token_endpoint_auth_method = "client_secret_basic";
          # headscale_api_key_path = pkgs.writeText "smth_else" secrets.headscale_api_key;
          headscale_api_key = secrets.headscale_api_key;
          # redirect_uri = "https://${cfg.extraDomain}.${config.vars.baseDomain}/admin/oidc/callback";
        }
      );
    };
  };

}
