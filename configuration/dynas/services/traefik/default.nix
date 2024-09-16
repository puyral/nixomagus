{ pkgs, ... }:
{
  imports = [
    ./static.nix
    ./dynamic
    ./module.nix
  ];
  services.traefik = {
    enable = true;
    dataDir = "/containers/traefik";
    group = "traefik";
    environmentFiles = [ ./secrets/ovh.env ];
  };
  users.groups.traefik = {
    members = [ "root" ];
  };
  users.users.traefik = {
    extraGroups = [
      "traefik"
      "docker"
    ];
  };

  # Runtime
  virtualisation.docker = {
    enable = true;
    listenOptions = [ "/var/run/docker.sock" ];
  };
  virtualisation.oci-containers.backend = "docker";

  systemd.services.traefik = {
    after = [ "traefik-docker-network.service" ];
    requires = [ "traefik-docker-network.service" ];
    partOf = [ "traefik-root.target" ];
    wantedBy = [ "traefik-root.target" ];
  };

  # network for docker
  systemd.services."traefik-docker-network" =
    let
      netName = "traefik";
    in
    {
      path = [ pkgs.docker ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStop = "docker network rm -f ${netName}";
      };
      script = ''
        docker network inspect ${netName} || docker network create ${netName}
      '';
      partOf = [ "traefik-root.target" ];
      wantedBy = [ "traefik-root.target" ];
    };

  systemd.targets."traefik-root" = {
    unitConfig = {
      Description = "Traefik root";
    };
  };
}
