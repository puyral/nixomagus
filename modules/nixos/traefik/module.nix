{ lib, config, ... }:
with lib;
let
  cfg = config.networking.traefik;
in
{
  options.networking =

    {
      traefik = {
        enable = mkEnableOption "traefik";

        baseDomain = mkOption {
          type = types.str;
          description = "the base domain";
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
