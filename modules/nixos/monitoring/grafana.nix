{ lib, config, ... }:
let
  enable = config.extra.monitoring.enable;
  cfg = config.extra.monitoring.grafana;
  lokiCfg = config.extra.monitoring.loki;
  prometheusCfg = config.extra.monitoring.prometheus;
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
    provision = {
      enable = true;
      dashboards.path = ./dashboards;
      datasources.settings = {
        apiVersion = 1;
        datasources = [
          {
            name = cfg.lokiDatasourceName;
            type = "loki";
            access = "proxy";
            url = "http://127.0.0.1:${builtins.toString lokiCfg.port}";
            isDefault = true;
            editable = false;
          }
          {
            name = cfg.prometheusDatasourceName;
            type = "prometheus";
            access = "proxy";
            url = "http://127.0.0.1:${builtins.toString prometheusCfg.port}";
            editable = false;
          }
        ];
      };
    };
  };

  networking.nginx.instances.grafana = {
    enable = true;
    port = cfg.port;
  };

}
