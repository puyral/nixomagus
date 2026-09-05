{ lib, config, ... }:
with lib;
{
  options.extra.forgejo = {
    enable = mkEnableOption "forgejo";
    dataDir = mkOption {
      type = types.path;
      default = "${config.params.locations.containers}/forgejo";
    };
    subdomain = mkOption {
      type = types.str;
    };
    providers = mkOption {
      type = with types; listOf str;
      example = [ "ovh-pl" ];
    };
    sshPort = mkOption {
      type = types.port;
      default = 222;
    };
  };
}
