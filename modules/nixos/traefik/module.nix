{ lib, config, ... }:
with lib;
{
  options.networking =

    {
      traefik = {
        enable = mkEnableOption "traefik";

        baseDomain = mkOption {
          type = types.str;
          description = "the base domain";
          default = "${config.extra.acme.domain}";
        };

        log.level = mkOption {
          type = types.enum [
            "TRACE"
            "DEBUG"
            "INFO"
            "WARN"
            "ERROR"
            "FATAL"
            "PANIC"
          ];
          default = "ERROR";
        };

        instances =
          let
            options = (import ./options.nix) lib;
          in
          mkOption {
            default = { };
            type =
              with types;
              attrsOf (submodule {
                inherit options;
              });
          };
      };
    };
}
