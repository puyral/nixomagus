{ config, lib, ... }:
with lib;
let
  cfg = config.extra.torrent;
in
{
  config.services.rtorrent = mkIf (cfg.enable && !cfg.containered) (
    with cfg;
    # if cfg.containered then
    #   { }
    # else
    {
      inherit downloadDir;
      enable = true;
      dataDir = "${dataDir}/rtorrent";
    }
    // (if user == null then { } else { inherit user; })
    // (if group == null then { } else { inherit group; })
  );
}
