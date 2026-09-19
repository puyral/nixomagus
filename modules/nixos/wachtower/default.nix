{ lib, config, ... }:
with lib;
with builtins;
let
  cfg = config.extra.watchtower;
in
{
  options.extra.watchtower = {
    enable = mkEnableOption "wachtower auto-update docker service";
    socket = mkOption {
      default = "/var/run/watchtower-docker.sock";
      type = types.str;
      description = "the docker socket";
    };
  };
  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = false;
        message = "watchtower isn't maintained anymore";
      }
    ];
    virtualisation.oci-containers.containers."watchtower" = {
      autoStart = true;
      image = "containrrr/watchtower";
      volumes = [ "${cfg.socket}:/var/run/docker.sock" ];
    };
    virtualisation.docker = mkIf cfg.enable {
      daemon.settings.hosts = [ "unix://${cfg.socket}" ];
    };
  };
}
