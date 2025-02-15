{
  config,
  lib,
  my-nixpkgs,
  pkgs-unstable,
  ...
}:
let
  cfg = config.extra.torrent;
in
{
  # imports = [ "${my-nixpkgs}/nixos/modules/services/web-apps/rutorrent.nix" ];
  config = {
    services = lib.mkIf (cfg.enable && !cfg.containered && cfg.rtorrent) {
      rutorrent = {
        # package = pkgs-unstable.rutorrent;
        enable = true;
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
