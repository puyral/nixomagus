{ config, lib, ... }:
let
  cfg = config.extra.mosquitto;
in
{
  imports = [ ./options.nix ];
  config = lib.mkIf cfg.enable {
    services.mosquitto = {
      enable = true;
      dataDir = "${config.params.locations.containers}/mosquitto";
    };
  };
}
