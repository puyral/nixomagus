{
  lib,
  config,
  computer,
  ...
}:
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
        providers = [ computer.name ] ++ cfg.extraProviders;
        enable = true;
        port = 9456;
        address = "$backend_pi";
        extraConfig = ''
          resolver ${cfg.resolver} valid=30s;
          set $backend_pi "${cfg.backend}";
        '';
      };
    };
    extra.acme = {
      enable = true;
      extraDomains = [ "${subdomain}.puyral.fr" ];
    };
  };

}
