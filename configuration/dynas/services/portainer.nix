{ config, ... }:
let
  name = "portainer";

  socket = "/var/run/portainer-docker.sock";
in
{

  virtualisation.oci-containers.containers.${name} = {
    image = "portainer/portainer-ce:latest";
    autoStart = true;
    ports = [ "9000:9000" ];
    volumes = [
      "/containers/portainer:/data"
      "${socket}:/var/run/docker.sock:rw"
    ];
  };
  virtualisation.oci-containers.proxy.containers.${name} = {
    port = 9000;
    domain = "dynas.puyral.fr";
  };
  virtualisation.docker = {
    daemon.settings.hosts = [ "unix://${socket}" ];
  };
}
