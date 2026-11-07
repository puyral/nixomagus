{ config, lib, ... }:

let
  cfg = config.vars.cfg;
  oidc = config.vars.oidc;
  domain = "${cfg.extraDomain}.${config.vars.baseDomain}";
  name = "headscale";
  port = cfg.headscale.port;
  clientSecretFile = config.sops.secrets."headscale/oidc-client-secret".path;

in
{
  # sops inside the container, decrypting with the host ssh key mounted at /etc/sops
  sops.age.sshKeyPaths = [ "/etc/sops" ];
  sops.secrets."headscale/oidc-client-secret" = {
    sopsFile = ./secrets.sops-secret.env;
    format = "dotenv";
    key = "HEADSCALE_OIDC_CLIENT_SECRET";
  };

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

      derp.server = {
        enabled = true;
        stun_listen_addr = "0.0.0.0:${builtins.toString cfg.derpPort}";
      };
      policy.mode = "database";
      node.expiry = "0";

      oidc = lib.mkIf config.vars.authcfg.enable {
        only_start_if_oidc_is_available = false;
        issuer = "https://${config.vars.authcfg.extraDomain}.${config.vars.baseDomain}";
        client_id = oidc.headscale.id;
        client_secret_path = clientSecretFile;
        use_expiry_from_token = false;
        scope = [
          "openid"
          "profile"
          "email"
          "groups"
        ];
        allowed_groups = [ ];
      };
    };
  };
  environment.systemPackages = [ config.services.headscale.package ];
}
