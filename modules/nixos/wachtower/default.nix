{ lib, config, ... }:
with lib builtins;
let
  cfg = config.services.watchtower;
in
{
  options.services.watchtower = {
    enable = mkEnableOption "wachtower auto-update docker service";
    socker = "/var/run/watchtower-docker.sock";
  };
  config = mkIf cfg.enable {

    virtualisation.oci-containers.containers."watchtower" = {
      autoStart = true;
      image = "containrrr/watchtower";
      volumes = [ "${cfg.socket}:/var/run/docker.sock" ];
    };
  };
}
