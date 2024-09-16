{ ... }:
{
  imports = [
    ./static.nix
    ./dynamic
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
    extraGroups = [ "traefik" ];
  };
}
