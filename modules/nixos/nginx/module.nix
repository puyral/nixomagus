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
