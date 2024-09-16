gconfig: vars:
{ config, ... }:
let
  listener = {
    acl = [
      "zigbee2mqtt"
      "hass/status"
    ];
    omitPasswordAuth = true;
    settings.allow_anonymous = true;
    port = 1883;
  };
in
{
  services.zigbee2mqtt = {
    enable = true;
    settings = {
      homeassistant = config.services.home-assistant.enable;
      permit_join = true;
      serial = {
        port = "/dev/ttyUSB1";
      };
      frontend.port = vars.z2m_port;
      advanced = {
        pan_id = 4564;
      };
    };
  };
  services.mosquitto = {
    enable = true;
    listeners = [ listener ];
    # settings = {allow_anonymous = true;};
  };
  networking.firewall.allowedTCPPorts = [
    config.services.zigbee2mqtt.settings.frontend.port
    listener.port
  ];
  networking.firewall.allowedUDPPorts = [ listener.port ];
}
