{
  config,
  pkgs-unstable,
  pkgs,
  lib,
  ...
}:
let
  port = 2342;
  gconfig = config;
  cfg = config.extra.photoprism;
in
{
  imports = [ ./options.nix ];
  config = lib.mkIf cfg.enable {
    sops.secrets.photoprism = {
      sopsFile = ./secrets-sops/photoprism.yaml;
      key = "init_password";
    };

    networking.nat.internalInterfaces = [ "ve-photoprism" ];
    containers.photoprism = {
      bindMounts = {
        "/originals" = {
          hostPath = cfg.photos;
          isReadOnly = false;
        };
        "/originals/videos" = {
          hostPath = cfg.videos;
          isReadOnly = false;
        };
        "/cache" = {
          hostPath = cfg.dataDir;
          isReadOnly = false;
        };
        "/var/lib/tailscale" = {
          hostPath = "${cfg.dataDir}/tailscale";
          isReadOnly = false;
        };
        "${gconfig.sops.secrets.photoprism.path}" = {
          hostPath = gconfig.sops.secrets.photoprism.path;
          isReadOnly = true;
        };
      };
      autoStart = true;
      ephemeral = true;

      config =
        { ... }:
        {
          environment.systemPackages = (
            with pkgs;
            [
              darktable
              ffmpeg
              exiftool
            ]
          );
          services.photoprism = {
            enable = true;
            originalsPath = "/originals";
            storagePath = "/cache";
            passwordFile = gconfig.sops.secrets.photoprism.path;
            settings = {
              PHOTOPRISM_ADMIN_USER = "root";
              PHOTOPRISM_INDEX_SCHEDULE = "@every 3h";

              PHOTOPRISM_THUMB_UNCACHED = "true";
              PHOTOPRISM_THUMB_SIZE = "2000";
              PHOTOPRISM_JPEG_SIZE = "10000";
              PHOTOPRISM_JPEG_QUALITY = "80";

              PHOTOPRISM_SITE_URL = "https://photos.puyral.fr/";
              PHOTOPRISM_SITE_CAPTION = "Photos";
              PHOTOPRISM_SITE_TITLE = "Photos";
              PHOTOPRISM_SITE_PREVIEW = "/originals/42207.jpg";

              PHOTOPRISM_WALLPAPER_URI = "/originals/42207.jpg";

              PHOTOPRISM_DISABLE_WEBDAV = "true";

              PHOTOPRISM_FFMPEG_BIN = "${pkgs.ffmpeg}/bin/ffmpeg";
              PHOTOPRISM_EXIFTOOL_BIN = "${pkgs.exiftool}/bin/exiftool";
            };
            inherit port;
            address = "0.0.0.0";
          };
          users.users.photoprism = {
            group = "photoprism";
            isSystemUser = true;
          };
          users.groups.photoprism.gid = gconfig.users.groups.photoprism.gid;

          services.tailscale.enable = true;
        };
    };
    extra.containers.photoprism = {
      vpn = true;

      traefik = [
        {
          inherit port;
          name = cfg.subdomain;
          enable = true;
          providers = cfg.providers;
          address = "100.64.0.10";
        }
      ];
    };
    users.groups.photoprism = {
      members = [
        "simon"
        "root"
      ];
      gid = 986;
    };
  };
}
