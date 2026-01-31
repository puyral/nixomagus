{ config, pkgs, ... }:
{
  # see https://patchwork.freedesktop.org/patch/674583/?series=154480&rev=2
  # see https://gitlab.freedesktop.org/drm/xe/kernel/-/issues/6221

  boot.kernelParams = [
  ];

  # drivers
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # QuickSync for Encoding
      intel-compute-runtime # OpenCL for Machine Learning (Immich)
      vpl-gpu-rt # Newer Video Processing Library
    ];
  };

  # GPU notifier in case of crash

  systemd.services.gpu-crash-monitor = {
    description = "Monitor Intel Xe GPU for crashes and notify";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    # Install necessary tools into the script's path
    path = with pkgs; [
      bash
      systemd # for journalctl
      util-linux # for dmesg
      zstd
      mailutils # for 'mail' command
      coreutils
    ];

    serviceConfig = {
      # Restart automatically if the monitoring script crashes
      Restart = "always";
      RestartSec = "10s";
      # Run as root to access dmesg/journal
      User = "root";
    };

    script = builtins.readFile ./monitor-crashes.sh;
  };

}
