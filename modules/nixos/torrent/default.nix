{ lib, config, ... }:
with lib;
let
  name = "torrent";
  port = "80";
  cfg = config.extra.torrent;
in

{
  imports = [ ./commun.nix ];
  config = mkIf cfg.containered {
    containers.torrent = {
      bindMounts = {
        "/data" = {
          hostPath = cfg.dataDir;
          isReadOnly = false;
        };
        "/download" = {
          hostPath = cfg.downloadDir;
          isReadOnly = false;
        };
        "/videos" = {
          hostPath = "/mnt/Zeno/media/videos";
          isReadOnly = false;
        };
      };
      autoStart = true;
      ephemeral = true;
      config =
        let
          users = config.users;
        in
        { config, ... }:
        {
          imports = [ ./commun.nix ];
          users = {
            users =
              if cfg.user == null then
                { }
              else
                {
                  "${cfg.user}" = {
                    uid = users.users."${cfg.user}".uid;
                    group = config.services.rtorrent.group;
                    isSystemUser = false;
                    isNormalUser = true;
                  };
                };
            groups =
              if cfg.group == null then { } else { "${cfg.group}".gid = users.groups."${cfg.group}".gid; };
          };

          extra.torrent = with cfg; {
            inherit user group;
            enable = true;
            dataDir = "/data";
            downloadDir = "/download";
          };
        };
    };
    extra.containers.torrent = {
      traefik = {
        port = 80;
        enable = true;
        name = "rutorrent";
      };
    };
  };
}
