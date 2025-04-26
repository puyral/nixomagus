{
  headplane,
  lib,
  config,
  ...
}:
let
  cfg = config.extra.headscale;
  name = "headscale";
in
{
  imports = [
    ./options.nix
    # ./headplane.nix
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
      };
      autoStart = true;
      ephemeral = true;
      forwardPorts = [
        {
          containerPort = 8080;
          hostPort = 8080;
          protocol = "tcp";
        }
        {
          containerPort = 8080;
          hostPort = 8080;
          protocol = "udp";
        }
      ];
      config =
        { ... }:
        {
          imports = [
            ((import ./headplane.nix) headplane cfg)
            ((import ./headscale.nix) cfg)
          ];
          options.vars = lib.mkOption { type = lib.types.attrs; };
          config.vars.baseDomain = config.networking.traefik.baseDomain;
        };
    };

    extra.containers.${name} =
      let
        domain = "${cfg.extraDomain}.${config.networking.traefik.baseDomain}";
      in
      {
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
  };
}
