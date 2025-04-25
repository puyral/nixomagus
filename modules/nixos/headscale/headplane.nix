headplane: cfg:
{
  config,
  ...
}:
let
  secrets = cfg.secrets or import ./secrets;
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
    enable = false;
    agent = {
      # As an example only.
      # Headplane Agent hasn't yet been ready at the moment of writing the doc.
      enable = true;
      settings = {
        HEADPLANE_AGENT_DEBUG = true;
        HEADPLANE_AGENT_HOSTNAME = "localhost";
        HEADPLANE_AGENT_TS_SERVER = "https://example.com";
        HEADPLANE_AGENT_TS_AUTHKEY = "xxxxxxxxxxxxxx";
        HEADPLANE_AGENT_HP_SERVER = "https://example.com/admin/dns";
        HEADPLANE_AGENT_HP_AUTHKEY = "xxxxxxxxxxxxxx";
      };
    };
    settings = {
      server = {
        inherit port;
        host = "0.0.0.0";
        cookie_secret = secrets.cookie_secret;
        cookie_secure = true;
      };
      headscale = {
        url = "0.0.0.0:${cfg.headscale.port}";
        public_url = "${cfg.headscale.extraDomain}.${config.vars.baseDomain}";
        config_strict = true;
      };
      integration.proc.enabled = true;
      # oidc = {
      #   issuer = "https://oidc.example.com";
      #   client_id = "headplane";
      #   client_secret = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
      #   disable_api_key_login = true;
      #   # Might needed when integrating with Authelia.
      #   token_endpoint_auth_method = "client_secret_basic";
      #   headscale_api_key = "xxxxxxxxxx.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
      #   redirect_uri = "https://oidc.example.com/admin/oidc/callback";
      # };
    };
  };

}
