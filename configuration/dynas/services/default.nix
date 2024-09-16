{ pkgs, config, ... }:
{
  imports = [
    ./nfs.nix
    ./samba.nix
    ./cockpit.nix
    ./syncthing.nix
    ./whatchtower.nix
    ./jellyfin.nix
    ./traefik
  ];

  # system.activationScripts.mkVPN = ''
  #   ${pkgs.docker}/bin/docker network create traefik
  # '';
  system.activationScripts.mkVPN =
    let
      docker = config.virtualisation.oci-containers.backend;
      dockerBin = "${pkgs.${docker}}/bin/${docker}";
    in
    ''
      ${dockerBin} network inspect traefik >/dev/null 2>&1 || ${dockerBin} network create traefik
    '';
}
