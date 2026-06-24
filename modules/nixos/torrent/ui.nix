{
  config,
  lib,
  pkgs-unstable,
  ...
}:
let
  cfg = config.extra.torrent;
  flood = true;
  rtorrent = !flood;
  rtorrentPaths = with pkgs-unstable; [
    php
    procps
    curl
    ffmpeg
    mediainfo
    sox
  ];
in
{
  config = {
    systemd.services.flood = lib.mkIf (flood && cfg.enable && !cfg.containered && cfg.rtorrent) {
      # otherwise the mapping of directories doesn't work
      serviceConfig = {
        DynamicUser = lib.mkForce false;
        BindPaths = "/run/rtorrent";
        User = "simon";

      };
    };

    # 1. Disable PrivateTmp for PHP-FPM so it drops files in the real /tmp
    systemd.services.phpfpm-rutorrent = lib.mkIf rtorrent {
      serviceConfig.PrivateTmp = lib.mkForce false;
      path = rtorrentPaths;
    };

    # 2. Add dependencies and disable PrivateTmp for rTorrent
    systemd.services.rtorrent = lib.mkIf (cfg.enable && !cfg.containered && cfg.rtorrent) {
      serviceConfig.PrivateTmp = lib.mkForce false;
      path = rtorrentPaths;
    };

    # 3. Force ownership of ruTorrent directory to rTorrent user/group so permissions align
    # and inject localHostedMode = true to bypass broken XMLRPC binary checks
    systemd.services.rutorrent-setup = lib.mkIf (cfg.enable && !cfg.containered && cfg.rtorrent && rtorrent) {
      postStart = ''
        CONFIG_PATH="${config.services.rutorrent.dataDir}/conf/config.php"
        cp --remove-destination $(readlink -f $CONFIG_PATH) $CONFIG_PATH
        echo "\$localHostedMode = true;" >> $CONFIG_PATH
        chown -R ${config.services.rtorrent.user}:${config.services.rtorrent.group} ${config.services.rutorrent.dataDir}/{conf,share,logs,plugins}
      '';
    };

    services = lib.mkIf (cfg.enable && !cfg.containered && cfg.rtorrent) {
      phpfpm.pools.rutorrent = lib.mkIf rtorrent {
        user = lib.mkForce config.services.rtorrent.user;
        group = lib.mkForce config.services.rtorrent.group;
        settings = {
          user = lib.mkForce config.services.rtorrent.user;
          group = lib.mkForce config.services.rtorrent.group;
          "clear_env" = "no";
        };
      };

      flood = lib.mkIf flood {
        enable = flood;
        #extraArgs = [''--rundir="${cfg.dataDir}/flood"''];
        port = 3000;
        openFirewall = true;
        host = "0.0.0.0";
      };

      rutorrent = lib.mkIf rtorrent {
        # Do NOT inherit user from rtorrent to avoid duplicate users.users key error in nixpkgs rutorrent.nix
        # user = "rutorrent"; # (defaults to rutorrent, which keeps the keys distinct)
        enable = rtorrent;
        hostName = "0.0.0.0";
        dataDir = "${cfg.dataDir}/rutorrent";
        nginx = {
          enable = true;
        };
        # they shouldn't be required with the default config but its pretty neat stuff that comes for free
        # basically as its part of the repo already
        plugins = [
          "httprpc"
          "data" # adds an http download optoion to the files tab
          # "diskspace"  #well shows diskspace
          "edit" # allows you to edit trackers of a torrent
          "erasedata" # allows deleting a torrent AND erasing data
          "theme" # allows custom themes
          "trafic" # traffic stats (yes its spelled like this)
          "seedingtime" # see
          "create" # make torrents
          "rss" # can use feeds
          # "throttle" #set speed limitations for torrents
          #"cookies" #if sb needs to auth to tracker with cookies
          #"retrackers" automatically adds our trackers tofiles
          "scheduler" # allows to set speed/ul/dl limitations based on daytime/time frames
          #"autotools" #do shit on lets say completed dl
          "datadir" # so you can change it
          "geoip" # so you can see nice lil country flags
          "tracklabels" # make a label for eachtracker
          "ratio" # ratio limits
          #"unpack" # so you can unrar/unzip downloaded shit
          "extsearch" # internal search function to many public/private trackers
          #"loginmgr" # for sites when cookies fail to use rss/pluginextsearch
          "rssurlrewrite" # rewrite http links for rss feeds with regular expressions
          #"feeds"
          "mediainfo"
          #"history"
          "screenshots"
          "spectrogram" # show the spectogram of torrent files
          "_task" # dependency for some of the plugins
          "uploadeta" # shows ETA
          "bulk_magnet" # pulk operations with magnets

          "check_port" # check if were connectable
          "filedrop" # drop files into it (multiple)
          "source" # download torrent file from ui back to client
          # "_getdir" #comfortable host fs navitator bar
        ];
      };
    };

  };
}
