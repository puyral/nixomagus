{ lib, config, ... }:
let
  cfg = config.extra.pi-ops-redirect;
  subdomain = "pi.${cfg.subdomain}";
in
{
  imports = [ ./options.nix ];
  config = lib.mkIf cfg.enable {
    networking.nginx.instances = {
      "pi" = {
        inherit subdomain;
        enable = true;
        port = 9456;
        address = "$backend_pi";
        extraConfig = ''
          resolver 127.0.0.53 valid=30s; # Or your LAN DNS / systemd-resolved IP
          set $backend_pi "sandbox.local";
        '';
      };
    };
    extra.acme = {
      enable = true;
      extraDomains = [ "${subdomain}.puyral.fr" ];
    };
  };

}
