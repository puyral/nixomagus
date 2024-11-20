{ lib, config, ... }:
let
  cfg = config.extra.monitoring.promtail;
in
lib.mkIf cfg.enable {
  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = cfg.port;
        grpc_listen_port = 0;
      };
      clients.url = "http://${cfg.lokiHost}:${builtins.toString cfg.lokiPort}/loki/api/v1/push";
      scrape_configs = [
        {
          job_name = "journal";
          journal = {
            max_age = "12h";
            labels = {
              job = "systemd-journal";
            };
          };
          relabel_configs = {
            source_labels = [ "__journal__systemd_unit" ];
            target_label = "unit";
          };
        }
      ];
    };
  };
}
