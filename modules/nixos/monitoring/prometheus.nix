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
        enabledCollectors = [
          "systemd"
          "hwmon"
          "cpufreq"
          "textfile"
        ];
        extraFlags = [ "--collector.textfile.directory=/var/lib/prometheus-node-exporter-textfiles" ];
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
      {
        job_name = "zigbee2mqtt";
        static_configs = [
          # Scraping the z2m container directly
          { targets = [ "${config.containers.z2m.localAddress}:8080" ]; }
        ];
      }
    ];

  };

  systemd.services.prometheus-gpu-exporter = {
    description = "Export GPU and NIC power metrics to prometheus textfile collector";
    wantedBy = [ "multi-user.target" ];
    script = ''
      mkdir -p /var/lib/prometheus-node-exporter-textfiles
      while true; do
        (
          # GPU Metrics (Intel Arc B580)
          GPU_STATUS=$(cat /sys/bus/pci/devices/0000:10:00.0/power/runtime_status 2>/dev/null || echo "unknown")
          GPU_VAL=0
          if [ "$GPU_STATUS" = "active" ]; then GPU_VAL=1; elif [ "$GPU_STATUS" = "suspended" ]; then GPU_VAL=0; fi
          echo "gpu_runtime_active $GPU_VAL"

          GPU_CUR_FREQ=$(cat /sys/class/drm/card0/device/tile0/gt0/freq0/cur_freq 2>/dev/null || echo 0)
          echo "gpu_cur_freq_mhz $GPU_CUR_FREQ"

          # NIC Metrics (Aquantia 10GbE)
          NIC_STATUS=$(cat /sys/bus/pci/devices/0000:0d:00.0/power/runtime_status 2>/dev/null || echo "unknown")
          NIC_VAL=0
          if [ "$NIC_STATUS" = "active" ]; then NIC_VAL=1; elif [ "$NIC_STATUS" = "suspended" ]; then NIC_VAL=0; fi
          echo "nic_10g_runtime_active $NIC_VAL"

        ) > /var/lib/prometheus-node-exporter-textfiles/gpu_metrics.prom.$$
        mv /var/lib/prometheus-node-exporter-textfiles/gpu_metrics.prom.$$ /var/lib/prometheus-node-exporter-textfiles/gpu_metrics.prom
        sleep 60
      done
    '';
    serviceConfig = {
      Restart = "always";
      RestartSec = "10s";
    };
  };
}
