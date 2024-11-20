{ pkgs, config, ... }:
{
  imports = [
    ./nfs.nix
    ./samba.nix
    ./cockpit.nix
    ./syncthing.nix
    ./jellyfin.nix
    ./homeassistant
    ./portainer.nix
    ./mosquitto.nix
    ./photos
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
      containered = true;
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
        enable = true;
        name = "dynas";
        lokiHost = "localhost";
        lokiPort = config.extra.monitoring.loki.port;
      };
    };

  };

  networking = {
    nat = {
      enable = true;
      externalInterface = "enp9s0";
    };
    traefik = {
      enable = true;
      baseDomain = "puyral.fr";
      docker.enable = true;
      log.level = "INFO";
    };
  };
}
