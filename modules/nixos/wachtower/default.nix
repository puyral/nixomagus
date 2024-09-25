{ lib, config, ... }:
with lib;
with builtins;
let
  cfg = config.services.watchtower;
in
{
  options.services.watchtower = {
    enable = mkEnableOption "wachtower auto-update docker service";
    socket = mkOption {
      default = "/var/run/watchtower-docker.sock";
      type = types.str;
      description = "the docker socket";
    };
  };
  config.virtualisation.oci-containers.containers."watchtower" = mkIf cfg.enable {
    autoStart = true;
    image = "containrrr/watchtower";
    volumes = [ "${cfg.socket}:/var/run/docker.sock" ];
  };
  config.virtualisation.docker = mkIf cfg.enable {
    # listenOptions = [
    #   "${cfg.socket}"
    # ];
    # extraOptions = "-H unix://${cfg.socket}";
    daemon.settings.hosts = [ "unix://${cfg.socket}" ];
  };
}
