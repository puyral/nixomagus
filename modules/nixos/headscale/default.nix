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
      config =
        { ... }:
        {
          imports = [
            ((import ./headplane.nix) headplane cfg)
            ((import ./headscale.nix) cfg)
          ];
          options.vars.baseDomain = lib.mkOption {
            type = lib.types.str;
          };
          config.vars.baseDomain = config.networking.traefik.baseDomain;
        };
    };

    extra.containers.${name} = {
      traefik = [
        {
          port = cfg.headscale.port;
          name = cfg.headscale.extraDomain;
          enable = true;
          providers = [ "ovh-pl" ];
        }
        {
          port = cfg.headplane.port;
          name = cfg.headplane.extraDomain;
          enable = true;
          providers = [ "ovh-pl" ];
        }
      ];
    };
  };
}
