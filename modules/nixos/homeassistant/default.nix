{ config, lib, ... }:
let
  cfg = config.extra.homeassistant;
  name = "homeassistant";
  port = 8123;
in
{
  imports = [ ./options.nix ];

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.${name} = {
      image = "homeassistant/home-assistant:latest";
      volumes = [ "${config.params.locations.containers}/homeassistant:/config:rw" ];
      autoStart = true;
    };
    virtualisation.oci-containers.proxy.containers.${name} = {
      inherit port;
      gzip-bomb.enable = true;
    };
  };

}
