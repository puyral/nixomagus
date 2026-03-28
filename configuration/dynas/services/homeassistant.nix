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
  networking.nginx.instances.${name} = {
    inherit port;
  };
}
