{
  pkgs,
  config,
  pkgs-unstable,
  ...
}:
{
  imports = [
    ./filesharing.nix
    ./syncthing.nix
    ./jellyfin.nix
    ./homeassistant.nix
    ./portainer.nix
    ./mosquitto.nix
    ./photos.nix
    ./github
    ./backup
  ];
  virtualisation.docker.autoPrune.enable = true;

  services.watchtower.enable = true;

  params.locations = {
    containers = "${config.vars.Zeno.mountPoint}/containers";
  };

  sops.secrets."paperless/ai_token" = {
    sopsFile = ../ai_token.sops-secret.env;
    format = "dotenv";
  };

  extra =
    let
      bookLocation = "${config.vars.Zeno.mountPoint}/media/books";
    in
    {
      acme.enable = true;
      mail.enable = true;

      zigbee2mqtt = {
        enable = true;
        dongle = "/dev/serial/by-id/usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_6c969fdb7c12ec119aa120c7bd930c07-if00-port0";
      };
      paperless = {
        enable = true;
        ai = {
          enable = true;
          tokenFile = config.sops.secrets."paperless/ai_token".path;
          ollamaModel = "mistral";
        };
        # backedupDir = "/mnt/Zeno/administratif/paperless";
      };

      torrent = {
        enable = true;
        user = "simon";
        group = "torrent";
        containered = true;
        transmission = false;
        rtorrent = true;
        downloadDir = "/mnt/Zeno/other/downloads";
        extraPaths = {
          "/videos" = "${config.vars.Zeno.mountPoint}/media/videos";
          "/books" = bookLocation;
        };
      };

      calibre-web = {
        enable = false;
        calibreLibrary = bookLocation;
        enableBookUploading = true;
        enableBookConversion = true;
      };

      kavita = {
        enable = true;
        library = bookLocation;
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

      smartd = {
        enable = true;
        disks = [
          # boot
          "nvme-SAMSUNG_MZVLB256HAHQ-00000_S444NB0K507384"
          #"ata-INTENSO_SSD_1642403001004929" # dead
          #"ata-INTENSO_SSD_1642403001012229" # dead
          #"wwn-0x500a0751e608b583" # spare # unplugged because useless

          # other
          "nvme-eui.0025385991b0d6e9" # l2arc
          # "nvme-eui.5cd2e4e8e6520100" # optane

          # Toshiba 3TB
          "wwn-0x5000039fc0c49a69"
          "wwn-0x5000039fc0c49d0f"
          "wwn-0x5000039fc0c4836a"
          "wwn-0x5000039fc0c49909"

          # seagate 4TB
          "wwn-0x5000c500e8fb38c1"
          "wwn-0x5000c500e8fb3c9a"
          "wwn-0x5000c500e8fb44a1"
          "wwn-0x5000c500e8fb8de4"
          "wwn-0x5000c500e95106dc" # spare

          # 10TB toshiba
          # "wwn-0x5000039b38d17cf2"
        ];
      };

      cache.enable = true;

      tailscale.exitNode = {
        enable = true;
        interfaces = [ config.vars.mainNetworkInterface ];
      };
      tailscale.exit-container.enable = false;

      llm = {
        enable = true;
        acceleration = "vulkan";
        data = "${config.params.locations.containers}/llm/ollama";
        defaultLLM = "ministral-3:14b";
      };

      n8n.enable = true;

      fileflows = {
        enable = true;
        networking.reverproxied = true;
        hardware.intelArc = true;
        mediaDirs = [
          "/mnt/Zeno/media/videos/Anime"
          "/mnt/Zeno/media/photos/video_clips"
        ];
      };

      autoBackup = {
        enable = true;
        toRemote.enable = true;
      };

      ntfy = {
        enable = true;
        url = "ntfy";
      };
    };
  services.ollama.package = pkgs-unstable.ollama-vulkan;

  networking = {
    nat = {
      enable = true;
      externalInterface = "enp13s0"; # 10gb
      # externalInterface = "enp10s0"; # 1gb
      # externalInterface = "wlp8s0"; # wifi
    };
    traefik = {
      enable = true;
      docker.enable = true;
      log.level = "INFO";
    };
  };
}
