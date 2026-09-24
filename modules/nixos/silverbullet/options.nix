{ lib, config, ... }:
with lib;
{
  options.extra.silverbullet = {
    enable = mkEnableOption "silverbullet";
    dataDir = mkOption {
      type = types.path;
      default = "${config.params.locations.containers}/silverbullet";
      description = "Folder to store SilverBullet's space.";
    };
    port = mkOption {
      type = types.port;
      default = 3000;
      description = "Port SilverBullet listens on inside the container.";
    };
    subdomain = mkOption {
      type = types.str;
      default = "silverbullet";
      description = "Subdomain to expose the service on.";
    };
    providers = mkOption {
      type = with types; listOf str;
      default = [ "dynas" ];
      description = "Machines that should proxy this service.";
    };
  };
}
