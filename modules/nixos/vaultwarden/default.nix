{ lib, config, ... }:
let
  cfg = config.exact.vaultwarden;
  name = "vaultwarden";
  port = 8222;
in
{
  options.extra.vaultwarden = with lib; {
    enable = mkEnableOption "vaultwarden";
    dongle = mkOption { type = types.path; };
    dataDir = mkOption {
      type = types.path;
      default = "${config.params.locations.containers}/vaultwarden";
    };
    config = mkIf cfg.enable {
      containers.${name} = {
        bindMounts = {
          "/var/lib/bitwarden_rs" = {
            hostPath = "${cfg.dataDir}/state";
            isReadOnly = false;
          };
          "/backup" = {
            hostPath = "${cfg.dataDir}/backup";
            isReadOnly = false;
          };
        };
        autoStart = true;
        ephemeral = true;

        config =
          { ... }:
          {
            services.vaultwarden = {
              enable = true;
              config = {
                ROCKET_ADDRESS = "0.0.0.0";
                ROCKET_PORT = port;
              };
              backupDir = "/backup";
            };
          };
      };
    };
  };
}
