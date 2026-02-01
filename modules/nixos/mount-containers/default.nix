{ config, lib, ... }:
let
  cfg = config.extra.mount-containers;
in
{
  options.extra.mount-containers = with lib; {
    enable = mkEnableOption "mount container folder over nfs";
    nasIp = mkOption {
      type = types.str;
      default = "${config.ips.dynas}";
      description = "the ip of the nas";
    };
    remotePath = mkOption {
      type = types.pathWith {
        inStore = false;
        absolute = true;
      };
      default = "/mnt/Zeno/containers";
    };
    localPath = mkOption {
      type = types.pathWith {
        inStore = false;
        absolute = true;
      };
      default = "/mnt/Zeno/containers";
    };
    nfsOptions = mkOption {
      type = types.listOf types.str;
      default = [
        "actimeo=60"
        "rw"
        "noatime"
        "nofail"
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    fileSystems."${cfg.localPath}" = {
      device = "${cfg.nasIp}:${cfg.remotePath}";
      fsType = "nfs";
      options = cfg.nfsOptions;
    };
  };
}
