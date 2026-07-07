{ lib, config, ... }:
with lib;
let
  name = "torrent";
  port = "80";
  cfg = config.extra.torrent;

  extraMounts = lib.mapAttrs (n: v: {
    hostPath = v;
    isReadOnly = false;
  }) cfg.extraPaths;
in

{

  imports = [ ./commun.nix ];
  config = mkIf (cfg.containered && cfg.containered) {

    containers.torrent = {
      bindMounts = extraMounts // {
        "/data" = {
          hostPath = cfg.dataDir;
          isReadOnly = false;
        };
        "/download" = {
          hostPath = cfg.downloadDir;
          isReadOnly = false;
        };
        # "/videos" = {
        #   hostPath = "${config.vars.Zeno.mountPoint}/media/videos";
        #   isReadOnly = false;
        # };
        "/var/lib/transmission" = {
          hostPath = "${cfg.dataDir}/transmission";
          isReadOnly = false;
        };
        "/var/lib/flood" = {
          hostPath = "${cfg.dataDir}/flood";
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
          nixpkgs.overlays = [
            (final: prev: {
              rutorrent = prev.rutorrent.overrideAttrs (oldAttrs: {
                postPatch = (oldAttrs.postPatch or "") + ''
                  substituteInPlace php/utility/fileutil.php \
                    --replace-fail 'getMinFilePerms( $file, $chmod = 755 )' 'getMinFilePerms( $file, $chmod = 0555 )' \
                    --replace-fail 'return((decoct($code) & 0777) >= $chmod);' 'return(($code & $chmod) == $chmod);'
                    
                  substituteInPlace conf/config.php \
                    --replace-fail '$localHostedMode = false;' '$localHostedMode = true;'
                '';
              });
            })
          ];
          imports = [ ./commun.nix ];
          users = {
            users =
              if cfg.user == null then
                { }
              else
                {
                  "${cfg.user}" = {
                    uid = lib.mkForce (users.users."${cfg.user}".uid);
                    group = lib.mkForce (cfg.group or config.services.rtorrent.group);
                    isSystemUser = false;
                    isNormalUser = true;
                  };
                };
            groups = {
              rtorrent = { };
            }
            // (if cfg.group == null then { } else { "${cfg.group}".gid = users.groups."${cfg.group}".gid; });
          };

          extra.torrent = with cfg; {
            inherit user group;
            enable = true;
            dataDir = "/data";
            downloadDir = "/download";
            transmission = cfg.transmission;
            rtorrent = cfg.rtorrent;
          };
        };
    };
    extra.containers.torrent = {
      nginx = [
        {
          port = 3000;
          enable = true;
          name = "rutorrent";
        }
        {
          port = 9091;
          enable = true;
          name = "transmission";
        }
      ];
    };
  };
}
