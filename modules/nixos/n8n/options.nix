{ lib, config, ... }:
with lib;
{
  options.extra.n8n = {
    enable = mkEnableOption "n8n";
    dataDir = mkOption {
      type = types.path;
      default = "${config.params.locations.containers}/n8n";
    };
    subdomain = mkOption {
      type = types.str;
      default = "n8n";
    };
  };
}
