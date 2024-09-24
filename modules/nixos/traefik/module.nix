{ lib, config, ... }:
with lib;
let
  cfg = config.networking.traefik;
in
{
  options.networking =

    {
      traefik = {
        enable = mkEnableOption;

        baseDomain = mkOption {
          type = types.str;
          description = "the base domain";
        };

        instance =
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
