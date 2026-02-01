{ config, lib, ... }:
let
  cfg = config.extra.mail-server;
  cfgCM = config.extra.mount-containers;

in
{
  config = lib.mkIf (cfg.enable && cfg.remoteStorage.enable) {
    assertions = [
      {
        assertion = cfgCM.enable;
        message = "`extra.mount-containers` needs to be enabled";
      }
      {
        assertion = lib.hasPrefix cfgCM.localPath cfg.remoteStorage.local;
        message = "`extra.mount-containers.localPath` must be a prefix for `extra.mail-server.remoteStorage.local`";
      }
    ];

    fileSystems."${cfg.dirs.data}/${cfg.dirs.mails}" = {
      device = "${cfg.remoteStorage.local}";
      fsType = "none";
      options = [
        "bind"
        "x-systemd.requires-mounts-for=${cfgCM.localPath}"
        "nofail"
      ];
    };
  };
}
