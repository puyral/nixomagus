{config, ...}:let name = "portainer" ; 

socket = builtins.head config.virtualisation.docker.listenOptions;
in {

  virtualisation.oci-containers.containers.${name}= {
    image = "portainer/portainer-ce:latest";
    autoStart = true;
    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.${name}.rule" = "Host(`${name}.dynas.puyral.fr`)";
      "traefik.http.routers.${name}.entrypoints" = "https";
      "traefik.http.routers.${name}.tls.certresolver" = "ovh";
      "traefik.http.services.${name}.loadbalancer.server.port" = "9000";
    };
    ports = ["9000:9000"];
    volumes = ["/containers/portainer:/data" "${socket}:/var/run/docker.sock:rw"];
  };
  systemd.services."docker-${name}" = {
    after = [ "traefik-docker-network.service" ];
    requires = [ "traefik-docker-network.service" ];
      wantedBy = [ "multi-user.target" ];
  };
}