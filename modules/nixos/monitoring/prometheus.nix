{ config, lib, ... }:

let
  enable = config.extra.monitoring.enable;
  cfg = config.extra.monitoring.prometheus;
in
lib.mkIf enable {
  services.prometheus = {
    enable = true;
    port = cfg.port;
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = cfg.port + 1;
      };
      zfs = {
        enable = true;
        port = cfg.port + 2;
      };
    };
    scrapeConfigs = [
      {
        job_name = "node-dynas";
        static_configs = [
          { targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ]; }
        ];
      }
      {
        job_name = "zfs-dynas";
        static_configs = [
          { targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.zfs.port}" ]; }
        ];
      }
    ];

  };
}
