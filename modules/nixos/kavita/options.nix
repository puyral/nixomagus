{ lib, config, ... }:
with lib;
{
  options.extra.kavita = {
    enable = mkEnableOption "kavita";
    subdomain = mkOption {
      type = types.str;
      default = "kavita";
    };
    dataDir = mkOption {
      type = types.path;
      default = "${config.params.locations.containers}/kavita";
    };
    library = mkOption {
      type = types.path;
    };
  };
}
