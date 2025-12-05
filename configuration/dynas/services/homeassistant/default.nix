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

  # docker.for.mac.localhost
    # labels = {
    #   "traefik.enable" = "true";
    #   "traefik.http.routers.${name}.entrypoints" = "https";
    #   "traefik.http.routers.${name}.rule" = "Host(`${name}.puyral.fr`)";
    #   "traefik.http.routers.${name}.tls.certresolver" = "ovh";
    #   "traefik.http.services.${name}.loadbalancer.server.port" = builtins.toString port;
    # };
    # extraOptions = [
    #   "--network-alias=${name}"
    #   "--network=traefik"
    # ];
    # environment = {
    #   TZ = config.time.timeZone;
    # };