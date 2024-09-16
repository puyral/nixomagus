{ config, pkgs, ... }:
{
  # Watchtower
  virtualisation.oci-containers.containers."watchtower" =
    let
      socket = builtins.head config.virtualisation.docker.listenOptions;
    in
    {
      autoStart = true;
      image = "containrrr/watchtower";
      volumes = [ "${socket}:/var/run/docker.sock" ];
    };
}
