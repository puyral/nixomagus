{ config, pkgs-unstable, ... }:
let
  port = 2342;
  gconfig = config;
in
{
  imports = [ ./generate-jpgs.nix ];
  networking.nat.internalInterfaces = [ "ve-photoprism" ];
  containers.photoprism = {
    bindMounts = {
      "/Volumes/Zeno/media/photos" = {
        hostPath = "/mnt/Zeno/media/photos";
        isReadOnly = true;
      };
      "/library.db" = {
        hostPath = "/mnt/Zeno/media/darktable-database/library.db";
        isReadOnly = true;
      };
      "/originals" = {
        hostPath = "/mnt/Zeno/media/photos/exports/complete";
        isReadOnly = false;
      };
      "/original/videos" = {
        hostPath = "/mnt/Zeno/media/photos/video_clips";
        isReadOnly = false;
      };
      "/cache" = {
        hostPath = "/containers/photoprism";
        isReadOnly = false;
      };
      # to retain the zt config
      "/var/lib/zerotier-one" = {
        hostPath = "/containers/photoprism/zerotier";
        isReadOnly = false;
      };
      "/var/lib/tailscale" = {
        hostPath = "/containers/photoprism/tailscale";
        isReadOnly = false;
      };
    };
    autoStart = true;
    ephemeral = true;

    config =
      { ... }:
      {
        environment.systemPackages = with pkgs-unstable; [
          darktable
          #{ inherit darktable gen-config; })
        ];
        services.photoprism = {
          enable = true;
          originalsPath = "/originals";
          storagePath = "/cache";
          passwordFile = ./secrets/init_password;
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
  extra.containers.photoprism.zerotierone = true;
  users.groups.photoprism = {
    members = [
      "simon"
      "root"
    ];
    gid = 986;
  };
}
