{ config, ... }:
{
  imports = [ ./module.nix ];
  my.homeassistant =
    let
      baseDir = config.params.location.containers;
    in
    {
      containers = {
        mosquitto = {
          image = "eclipse-mosquitto:latest";
          volumes = [
            "${baseDir}/mosquitto:/mosquitto:rw"
            "${baseDir}/mosquitto/log:/mosquitto/log:rw"
            "${baseDir}/mosquitto/data:/mosquitto/data:rw"
          ];
          ports = [ "1883:1883" ];
          # log-driver = "journald";
        };

        zigbee2mqtt = {
          port = 8080;
          image = "koenkk/zigbee2mqtt:latest";
          volumes = [
            "${baseDir}/zigbee2mqtt:/app/data:rw"
            "/run/udev:/run/udev:ro"
          ];
          dependsOn = [ "mosquitto" ];
          # log-driver = "journald";
          extraOptions = [
            "--device=/dev/serial/by-id/usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_6c969fdb7c12ec119aa120c7bd930c07-if00-port0:/dev/ttyUSB0"
          ];
        };

        homeassistant = {
          port = 8123;
          image = "homeassistant/home-assistant:latest";
          volumes = [ "${baseDir}/homeassistant:/config:rw" ];
          dependsOn = [ "mosquitto" ];
          # log-driver = "journald";
        };

      };
    };
}
