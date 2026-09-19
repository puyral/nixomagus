{ config, lib, ... }: {
  options.extra.mosquitto = with lib; {
    enable = mkEnableOption "mosquitto broker";
    dataDir = "${config.params.locations.containers}/mosquitto";
  };
}
