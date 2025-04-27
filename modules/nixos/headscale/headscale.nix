{ config, lib, ... }:

let
  cfg = config.vars.cfg;
  oidc = config.vars.oidc;
  domain = "${cfg.extraDomain}.${config.vars.baseDomain}";
  name = "headscale";
  port = cfg.headscale.port;

in
{
  services.headscale = {
    inherit port;
    enable = true;
    address = "0.0.0.0";
    settings = {
      logtail.enabled = false;
      #log.level = "debug";
      server_url = "https://${domain}";
      dns = {
        base_domain = "hs.${config.vars.baseDomain}";
        nameservers.global = [ "1.1.1.1" ];
        magic_dns = false;
      };

      derp = {
        stun_listen_addr = "0.0.0.0:${builtins.toString cfg.derpPort}";
      };
      policy.mode = "database";

      oidc = lib.mkIf config.vars.authcfg.enable {
        only_start_if_oidc_is_available = true;
        issuer = "https://${config.vars.authcfg.extraDomain}.${config.vars.baseDomain}";
        client_id = oidc.headscale.id;
        client_secret = oidc.headscale.plain;
        expiry = "0";
        use_expiry_from_token = false;
        scope = [
          "openid"
          "profile"
          "email"
          "groups"
        ];
        allowed_groups = [ ];
        strip_email_domain = true;

      };
    };
  };
  environment.systemPackages = [ config.services.headscale.package ];
}
