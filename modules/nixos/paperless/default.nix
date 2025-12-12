{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.extra.paperless;
  name = "paperless";
  port = 28981;
  dataDir = cfg.dataDir;
  user = name;
in
{
  options.extra.paperless = with lib; {
    enable = mkEnableOption name;
    dataDir = mkOption {
      type = types.path;
      default = "${config.params.locations.containers}/${name}";
    };
    mediaDir = mkOption {
      type = types.path;
      default = "${config.vars.Zeno.mountPoint}/paperless";
    };
    incommingDir = mkOption {
      type = types.path;
      default = "${config.vars.Zeno.mountPoint}/administratif/paperless";
    };
    backupDir = mkOption {
      type = types.path;
      default = "${config.vars.Zeno.mountPoint}/administratif/backup";
    };
  };
  config = lib.mkIf cfg.enable {
    containers.${name} = {
      bindMounts = {
        "/data" = {
          hostPath = dataDir;
          isReadOnly = false;
        };
        "/media" = {
          hostPath = cfg.mediaDir;
          isReadOnly = false;
        };
        "/incomming" = {
          hostPath = cfg.incommingDir;
          isReadOnly = false;
        };
        "/backup" = {
          hostPath = cfg.backupDir;
          isReadOnly = false;
        };
      };
      autoStart = true;
      ephemeral = true;
      config =
        { ... }:
        let
          paperless = pkgs.paperless-ngx;
        in
        {
          environment.systemPackages = with pkgs; [ paperless ];
          services.paperless = {
            inherit port user;
            # package =  pkgs.paperless-ngx.overrideAttrs (final: prev: {doTest = false;});
            # package = extra-pkgs.paperless-nixpkgs.paperless-ngx;
            package = paperless;
            enable = true;
            dataDir = "/data";
            mediaDir = "/media";
            consumptionDir = "/incomming";
            consumptionDirIsPublic = true;
            passwordFile = ./secrets/PASSWORD;
            settings = rec {
              PAPERLESS_ADMIN_USER = "simon";
              PAPERLESS_CONSUMER_IGNORE_PATTERN = [
                ".DS_STORE/*"
                "._*"
                "desktop.ini"
              ];
              PAPERLESS_CONSUMER_RECURSIVE = true;
              PAPERLESS_OCR_LANGUAGE = "fra+deu+eng";
              PAPERLESS_OCR_USER_ARGS = {
                optimize = 1;
                pdfa_image_compression = "lossless";
              };
              PAPERLESS_OCR_SKIP_ARCHIVE_FILE = "with_text";
              PAPERLESS_TRUSTED_PROXIES = config.containers.${name}.hostAddress;
              PAPERLESS_URL = "https://${name}.${config.networking.traefik.baseDomain}";
              # PAPERLESS_CSRF_TRUSTED_ORIGINS = "${PAPERLESS_URL},${PAPERLESS_TRUSTED_PROXIES}";
            };
            address = "0.0.0.0";

            exporter = {
              enable = true;
              directory = "/backup";
            };
          };
          users.groups.${user}.gid = lib.mkForce config.users.groups.${user}.gid;
          users.groups.syncthing = {
            members = [ user ];
            gid = config.users.groups.syncthing.gid;
          };
        };
    };
    extra.containers.${name} = {
      traefik = [
        {
          inherit port;
          enable = true;
        }
      ];
    };
  };
}
