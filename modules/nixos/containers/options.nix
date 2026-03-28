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
            nginx =
              let
                inner_nginx_options = (import ../nginx/options.nix) lib // {
                  name = mkOption {
                    type = types.str;
                    default = name;
                    description = "the subdomain name";
                  };
                  enable = mkEnableOption "nginx redirection";
                };
              in
              mkOption {
                default = [ ];
                description = "reverse proxy configurations (nginx)";
                type = types.listOf (types.submodule { options = inner_nginx_options; });
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
