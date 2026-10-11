{ config, lib, ... }:
let
  cfg = config.extra.homeassistant;
  name = "homeassistant";
  port = 8123;
in
{
  imports = [ ./options.nix ];

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.${name} = {
      image = "homeassistant/home-assistant:latest";
      volumes = [ "${config.params.locations.containers}/homeassistant:/config:rw" ];
      autoStart = true;
    };
    virtualisation.oci-containers.proxy.containers.${name} = {
      inherit port;
      gzip-bomb.enable = true;
    };
    # TODO: move to a container to free port 8081
    services.openthread-border-router = {
  enable = true;
  web = {
    enable = true;
    listenAddress = "0.0.0.0";
  };
  radio = {
    device = "/dev/serial/by-id/usb-Espressif_USB_JTAG_serial_debug_unit_58:E6:C5:12:FA:E8-if00";
    baudRate = 460800;
    flowControl = false;   # the guide says disable HW flow control for the C6
  };
  backboneInterfaces = ["enp10s0"];
  # also set the backbone interface to your NAS's LAN NIC (check option name)
};

services.matter-server.enable = true;
# services.home-assistant.extraComponents = [ "otbr" "thread" "matter" ];
  };

}
