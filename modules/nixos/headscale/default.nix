{
  headplane,
  lib,
  config,
  ...
}:
let
  cfg = config.extra.headscale;
  authcfg = config.extra.authelia;
  oidc = authcfg.oidc.secrets;
  name = "headscale";
in
{
  imports = [
    ./options.nix
  ];
  config = lib.mkIf cfg.enable {

    containers.${name} = {
      bindMounts = {
        "/var/lib/headscale" = {
          hostPath = cfg.headscale.dataDir;
          isReadOnly = false;
        };
        "/var/lib/headplane" = {
          hostPath = cfg.headplane.dataDir;
          isReadOnly = false;
        };
        "/var/lib/tailscale" = {
          hostPath = "${cfg.headscale.dataDir}/tailscale";
          isReadOnly = false;
        };
      };
      autoStart = true;
      ephemeral = true;
      forwardPorts = [
        {
          containerPort = cfg.derpPort;
          hostPort = cfg.derpPort;
          protocol = "udp";
        }
      ];
      config =
        { ... }:
        {
          imports = [
            ((import ./headplane.nix) headplane)
            ./headscale.nix
          ];
          options.vars = lib.mkOption { type = lib.types.attrs; };
          config = {
            vars = {
              inherit
                cfg
                authcfg
                oidc
                ;
              baseDomain = config.networking.traefik.baseDomain;
            };
            services.tailscale.enable = true;
          };
        };
    };

    extra.containers.${name} =
      let
        domain = "${cfg.extraDomain}.${config.networking.traefik.baseDomain}";
      in
      {
        vpn = true;
        traefik = [
          {
            port = cfg.headscale.port;
            enable = true;
            providers = [ "ovh-pl" ];
            extra.rule = "Host(`${domain}`) && PathPrefix(`/`)";
          }
          {
            port = cfg.headplane.port;
            name = "headplane";
            enable = true;
            providers = [ "ovh-pl" ];
            extra.rule = "Host(`${domain}`) && PathPrefix(`/admin`)";
          }
        ];
      };
    networking.firewall.allowedUDPPorts = [ cfg.derpPort ];
  };
}
