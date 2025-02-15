{ config, lib, ... }:
let
  cfg = config.extra.calibre-web;
  myMkEnbale =
    str:
    lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = str;
    };
  port = cfg.port;
  name = cfg.name;
  dataDir = cfg.dataDir;
in
{
  options.extra.calibre-web = with lib; {
    enable = mkEnableOption "calibre-web";
    calibreLibrary = mkOption {
      type = types.path;
      description = "location of calibre library";
    };
    dataDir = mkOption {
      type = types.path;
      default = "/containers/calibre";
    };
    enableBookUploading = myMkEnbale "enable book uploading for ui";
    enableBookConversion = myMkEnbale "enable book conversion";
    port = mkOption {
      type = types.port;
      default = 8083;
    };
    name = mkOption {
      type = types.str;
      default = "calibre";
    };
  };

  config = lib.mkIf cfg.enable {
    containers.${name} = {
      bindMounts = {
        "/var/lib/calibre" = {
          hostPath = dataDir;
          isReadOnly = false;
        };
        "/library" = {
          hostPath = cfg.calibreLibrary;
          isReadOnly = false;
        };
      };
      autoStart = true;
      ephemeral = true;
      config =
        { ... }:
        {
          services.calibre-web = {
            listen = {
              inherit port;
              ip = "0.0.0.0";
            };
            options = with cfg; {
              inherit enableBookUploading enableBookConversion;
              calibreLibrary = "/library";
            };
            enable = true;
            openFirewall = true;
            group = "${name}";
            dataDir = "/calibre";
          };
          users.groups.${name}.gid = config.users.groups.${name}.gid;
        };
    };

    extra.containers.${name} = {
      traefik = [
        {
          inherit port name;
          enable = true;
        }
      ];
    };

    extra.extraGroups.${name} = {
      gid = 1200;
    };
  };
}
