{ config, lib, ... }:
let
  cfg = config.extra.zigbee2mqtt;
  name = "z2m";
  port = 8080;
  mqtt = "mqtt://${config.containers.${name}.hostAddress}:${builtins.toString mqtt_port}";

  usb_donlge = cfg.dongle;
  mqtt_port = cfg.mqttPort;
  dataDir = cfg.dataDir;
in
{
  imports = [
    ./options.nix
    ./mosquitto.nix
  ];
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
              homeassistant.enabled = true;
              permit_join = false;
              serial = {
                port = "/dev/ttyUSB1";
                adapter = "zstack";
              };
              frontend.port = port;
              advanced = {
                pan_id = 4564;
                metrics = true;
              };
              mqtt.server = mqtt;
            };
          };
        };
    };
    extra.containers.${name} = {
      nginx = [
        {
          inherit port;
          name = "zigbee2mqtt";
          enable = true;
        }
      ];
    };
  };
}
