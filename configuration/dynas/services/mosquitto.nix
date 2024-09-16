{ ... }:
let
  listener = {
    # acl = [
    #   "zigbee2mqtt"
    #   "hass/status"
    # ];
    omitPasswordAuth = true;
    settings.allow_anonymous = true;
    port = 1883;
  };
in
{
  services.mosquitto = {
    enable = true;
    dataDir = "/containers/mosquitto";
    listeners = [ listener ];
    # settings = {allow_anonymous = true;};
  };
  networking.firewall # .interfaces."br-*"
  .allowedTCPPorts = [ listener.port ];
}
