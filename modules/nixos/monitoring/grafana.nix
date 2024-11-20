{ lib, config, ... }:
let
  enable = config.extra.monitoring.enable;
  cfg = config.extra.monitoring.grafana;
in
lib.mkIf enable {
  services.grafana = {
    enable = true;
    # addr = "127.0.0.1";
    settings = {
      server = {
        domain = cfg.domain;
        http_port = cfg.port;
        # http_addr = "0.0.0.0";
      };
    };
  };

  networking.traefik.instances.grafana = {
    enable = true;
    port = cfg.port;
  };

}
