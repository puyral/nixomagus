{ config, lib, ... }:
let
  cfg = config.extra.tailscale.exit-container;
  name = "ts-exitnode";
in
{
  options.extra.tailscale.exit-container = with lib; {
    enable = mkEnableOption "container that can serve as a tailscale exit node";
    dataDir = mkOption {
      type = types.path;
      default = "${config.params.locations.containers}/tailscale-exit";
    };
  };

  config = lib.mkIf cfg.enable {
    containers.${name} = {
      autoStart = true;
      ephemeral = true;
      bindMounts = {
        "/var/lib/tailscale" = {
          hostPath = "${cfg.dataDir}";
          isReadOnly = false;
        };
      };

      config =
        { ... }:
        {
          imports = [ ../tailscale ];
          extra.tailscale = {
            enable = true;
          };
        };
    };
    extra.containers.${name} = {
      vpn = true;
    };
  };
}
