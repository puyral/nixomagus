{ config, ... }:
let
  name = "homeassistant";
  port = 8123;
in

{
  # docker.for.mac.localhost
  virtualisation.oci-containers.containers.homeassistant = {
    image = "homeassistant/home-assistant:latest";
    volumes = [ "/containers/homeassistant:/config:rw" ];
    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.${name}.entrypoints" = "https";
      "traefik.http.routers.${name}.rule" = "Host(`${name}.puyral.fr`)";
      "traefik.http.routers.${name}.tls.certresolver" = "ovh";
      "traefik.http.services.${name}.loadbalancer.server.port" = builtins.toString port;
    };
    autoStart = true;
    extraOptions = [
      "--network-alias=${name}"
      "--network=traefik"
    ];
    environment = {
      TZ = config.time.timeZone;
    };
  };
}
