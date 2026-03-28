{ lib, ... }:
{
  virtualisation.docker.enable = lib.mkDefault true;
  virtualisation.docker.daemon.settings.hosts = [ "unix:///var/run/docker.sock" ];
  virtualisation.oci-containers.backend = "docker";
}
