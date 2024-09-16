{ mconfig, config, ... }:
# {...}:{
#     services.zigbee2mqtt = {
#     enable = true;
#     settings = {
#       homeassistant = true;
#       permit_join = true;
#       serial = {
#         port = "/dev/ttyUSB1";
#       };
#       frontend.port = vars.z2m_port;
#       advanced = {
#         pan_id = 4564;
#       };
#     };
#   };
# }
let
  name = "zigbee2mqtt";
  usb_donlge = "/dev/serial/by-id/usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_6c969fdb7c12ec119aa120c7bd930c07-if00-port0";
  port = 8080;
  mqtt_port = (builtins.head config.services.mosquitto.listeners).port;
  mqtt = "mqtt://localhost:${builtins.toString mqtt_port}";
in
{
  services.zigbee2mqtt = {
    enable = true;
    dataDir = "/containers/zigbee2mqtt";
    settings = {
      homeassistant = true;
      permit_join = true;
      serial = {
        port = usb_donlge;
      };
      frontend.port = port;
      advanced = {
        pan_id = 4564;
      };
      mqtt.server = mqtt;
    };
  };
  services.traefik.dynamicConfigOptions.http = {
    routers.${name} = {
      rule = "Host(`${name}.puyral.fr`)";
      entrypoints = "https";
      tls.certResolver = "ovh";
      service = name;
    };
    services.${name} = {
      loadBalancer.servers = [ { url = "http://localhost:${builtins.toString port}"; } ];
    };
  };

}
