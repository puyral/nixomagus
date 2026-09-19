{ lib, config, ... }: {
  options.extra.zigbee2mqtt = with lib; {
    enable = mkEnableOption "zigbee2mqtt";
    dongle = mkOption { type = types.path; };
    dataDir = mkOption {
      type = types.path;
      default = "${config.params.locations.containers}/zigbee2mqtt";
    };
    mqttPort = mkOption {
      type = types.port;
      default = 1883;
    };
  };
}
