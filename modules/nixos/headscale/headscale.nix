cfg:
{ config, ... }:

let
  domain = "${cfg.headscale.extraDomain}.${config.vars.baseDomain}";
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
      server_url = "https://${domain}";
      dns = {
        base_domain = "hs.${config.vars.baseDomain}";
      };
    };
  };
  environment.systemPackages = [ config.services.headscale.package ];
}
