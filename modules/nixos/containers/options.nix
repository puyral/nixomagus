{ lib, ... }:
with lib;
{
  options.extra.containers =
    let
      options =
        { name, ... }:
        {
          options = {
            vpn = mkEnableOption "vpn access";
            gpu = mkEnableOption "gpu passthough";
            traefik =
              let
                inner_tf_options = (import ../traefik/options.nix) lib // {
                  name = mkOption {
                    type = types.str;
                    default = name;
                    description = "the subdomain name";
                  };
                  enable = mkEnableOption "traefik redirection";
                };
              in
              mkOption {
                default = [ ];
                description = "reverse proxy configurations";
                type = types.listOf (types.submodule { options = inner_tf_options; });
              };
            privateNetwork = mkOption {
              type = types.bool;
              default = true;
            };
          };
        };
    in
    mkOption {
      type = types.attrsOf (types.submodule options);
      default = { };
    };
}
