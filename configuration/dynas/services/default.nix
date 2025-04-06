{ pkgs, config, ... }:
{
  imports = [
    ./filesharing.nix
    # ./cockpit.nix
    ./syncthing.nix
    ./jellyfin.nix
    ./homeassistant
    ./portainer.nix
    ./mosquitto.nix
    ./tailscale.nix
    ./photos.nix
    ./github
  ];
  virtualisation.docker.autoPrune.enable = true;

  services.watchtower.enable = true;

  extra = {
    zigbee2mqtt = {
      enable = true;
      dongle = "/dev/serial/by-id/usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_6c969fdb7c12ec119aa120c7bd930c07-if00-port0";
    };
    paperless = {
      enable = true;
      # backedupDir = "/mnt/Zeno/administratif/paperless";
    };

    torrent = {
      enable = true;
      user = "simon";
      group = "torrent";
      containered = true;
      downloadDir = "/mnt/Zeno/other/download";
      transmission = true;
      rtorrent = true;
    };

    calibre-web = {
      enable = true;
      calibreLibrary = "/mnt/Zeno/media/books";
      enableBookUploading = true;
      enableBookConversion = true;
    };

    monitoring = {
      enable = true;
      promtail = {
        enable = false;
        name = "dynas";
        lokiHost = "localhost";
        lokiPort = config.extra.monitoring.loki.port;
      };
    };

    cache.enable = true;
  };

  networking = {
    nat = {
      enable = true;
      externalInterface = "enp13s0"; # 10gb
      # externalInterface = "enp10s0"; # 1gb
      # externalInterface = "wlp8s0"; # wifi
    };
    traefik = {
      enable = true;
      baseDomain = "puyral.fr";
      docker.enable = true;
      log.level = "INFO";
    };
  };
}
