{ config, ... }:
let
  name = "homeassistant";
  port = 8123;
in

{
  virtualisation.oci-containers.containers.${name} = {
    image = "homeassistant/home-assistant:latest";
    volumes = [ "${config.params.locations.containers}/homeassistant:/config:rw" ];
    autoStart = true;
  };
  virtualisation.oci-containers.proxy.containers.${name} = {
    inherit port;
  };
}
