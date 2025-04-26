cfg:
{ config, ... }:

let
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
      server_url = "https://${domain}:443";
      dns = {
        base_domain = "hs.${config.vars.baseDomain}";
        nameservers.global = [ "1.1.1.1" ];
      };
      log.level = "debug";
    };
  };
  environment.systemPackages = [ config.services.headscale.package ];
}
