{ config, lib, ... }:
let
  cfg = config.extra.zigbee2mqtt;
  name = "z2m";
  # usb_donlge = "/dev/serial/by-id/usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_6c969fdb7c12ec119aa120c7bd930c07-if00-port0";
  usb_donlge = cfg.dongle;
  port = 8080;
  mqtt_port = (builtins.head config.services.mosquitto.listeners).port;
  mqtt = "mqtt://${config.containers.${name}.hostAddress}:${builtins.toString mqtt_port}";
  dataDir = cfg.dataDir;
in
{
  options.extra.zigbee2mqtt = with lib; {
    enable = mkEnableOption "zigbee2mqtt";
    dongle = mkOption { type = types.path; };
    dataDir = mkOption {
      type = types.path;
      default = "${config.params.locations.containers}/zigbee2mqtt";
    };
  };
  config = lib.mkIf cfg.enable {
    containers.${name} = {
      bindMounts = {
        "/data" = {
          hostPath = dataDir;
          isReadOnly = false;
        };
        "/dev/ttyUSB1" = {
          hostPath = usb_donlge;
          isReadOnly = false;
        };
      };
      allowedDevices = [
        {
          modifier = "rw";
          node = usb_donlge;
        }
      ];
      autoStart = true;
      ephemeral = true;
      config =
        { ... }:
        {
          services.zigbee2mqtt = {
            enable = true;
            dataDir = "/data";
            settings = {
              homeassistant = true;
              permit_join = true;
              serial = {
                port = "/dev/ttyUSB1";
              };
              frontend.port = port;
              advanced = {
                pan_id = 4564;
              };
              mqtt.server = mqtt;
            };
          };
        };
    };
    extra.containers.${name} = {
      traefik = [
        {
          inherit port;
          name = "zigbee2mqtt";
          enable = true;
        }
      ];
    };
  };
}
