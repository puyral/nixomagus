{ ... }:
{
  virtualisation.oci-containers.containers."docker-test-whoami" = {
    image = "traefik/whoami";
    autoStart = true;
    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.whoami.rule" = "Host(`whoami.puyral.fr`)";
      "traefik.http.routers.whoami.entrypoints" = "https";
      "traefik.http.routers.whoami.tls.certresolver" = "ovh";
    };
  };
  systemd.services."docker-test-whoami" = {
    after = [ "traefik-docker-network.service" ];
    requires = [ "traefik-docker-network.service" ];
    partOf = [ "traefik-root.target" ];
    wantedBy = [ "traefik-root.target" ];
  };
}
