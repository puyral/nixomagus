{ config, lib, ... }:
let
  cfg = config.extra.zigbee2mqtt;

  listener = {
    acl = [ "pattern readwrite #" ];
    omitPasswordAuth = true;
    settings.allow_anonymous = true;
    port = cfg.mqttPort;
  };

in

{
  config = lib.mkIf cfg.enable {
    extra.mosquitto.enable = lib.mkDefault true;
    services.mosquitto.listeners = [ listener ];
    networking.firewall.allowedTCPPorts = [ listener.port ];
  };
}
