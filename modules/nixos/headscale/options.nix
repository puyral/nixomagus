{ lib, config, ... }:
{
  options.extra.headscale = with lib; {
    enable = mkEnableOption "headscale";
    secrets = mkOption {
      type = types.nullOr types.attrs;
      default = null;
    };
    headscale = {
      extraDomain = mkOption {
        type = types.str;
      };
      port = mkOption {
        type = types.port;
        default = 8080;
      };
      dataDir = mkOption {
        type = types.path;
        default = "/containers/headscale";
      };
    };
    headplane = {
      extraDomain = mkOption {
        type = types.str;
      };
      port = mkOption {
        type = types.port;
        default = 3000;
      };
      dataDir = mkOption {
        type = types.path;
        default = "/containers/headplane";
      };
    };
    # baseDomain = mkOption {
    #   type = types.str;
    #   default = config.networking.traefik.baseDomain;
    # };
  };
}
