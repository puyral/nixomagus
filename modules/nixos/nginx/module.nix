{ lib, config, ... }:
with lib;
{
  options.networking =
    {
      nginx = {
        enable = mkEnableOption "nginx";

        baseDomain = mkOption {
          type = types.str;
          description = "the base domain";
          default = "${config.extra.acme.domain}";
        };

        instances =
          mkOption {
            default = { };
            type =
              with types;
              attrsOf (submodule {
                options = (import ./options.nix) { inherit lib config; };
              });
          };

        chainingPort = mkOption {
          default = null;
          type = types.nullOr types.port;
          description = "port to listen to for TLS chaining";
        };
      };
    };
}
