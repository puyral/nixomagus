{ lib, config, ... }:
let
  cfg = config.extra.monitoring.promtail;
in
lib.mkIf cfg.enable {
  users.users.promtail.extraGroups = [
    "systemd-journal-remote"
    "systemd-journal"
  ];
  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = cfg.port;
        grpc_listen_port = 0;
      };
      clients = [
        {
          url = "http://${cfg.lokiHost}:${builtins.toString cfg.lokiPort}/loki/api/v1/push";
        }
      ];
      scrape_configs = [
        {
          job_name = "journal";
          journal = {
            max_age = "12h";
            labels = {
              job = "systemd-journal";
              host = cfg.name;
            };
          };
          relabel_configs = [
            {
              source_labels = [ "__journal__systemd_unit" ];
              target_label = "unit";
            }
          ];
        }
        {
          job_name = "remote-journal";
          journal = {
            path = "/var/log/journal/remote";
            max_age = "12h";
            labels = {
              job = "remote-journal";
            };
          };
          relabel_configs = [
            {
              source_labels = [ "__journal__hostname" ];
              target_label = "container";
            }
            {
              source_labels = [ "__journal__systemd_unit" ];
              target_label = "unit";
            }
          ];
        }
      ];
    };
  };
}
