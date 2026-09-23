{ config, lib, ... }:
let
  cfg = config.extra.copyparty;
in
{
  imports = [ ./options.nix ];
  config = lib.mkIf cfg.enable {
    networking.nginx.instances = with cfg; {
      "${subdomain}" = {
        inherit port;
        enable = true;
        providers = [
          "dynas"
          defaultGateway
        ];
        gzip-bomb.enable = true;
        extraConfig = ''
          proxy_set_header X-Forwarded-Proto https;
        '';
      };
    };
  };
}
