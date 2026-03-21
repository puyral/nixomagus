{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.extra.esphome;
  # mqtt_port = (builtins.head config.services.mosquitto.listeners).port;
  # mqtt = "mqtt://localhost:${builtins.toString mqtt_port}";

in
{
  options.extra.esphome = with lib; {
    enable = mkEnableOption "esphome";
    address = mkOption {
      type = types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    services.esphome = {
      enable = true;
      address = cfg.address;
      openFirewall = true;
    };
  };
}
