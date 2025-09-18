{ config, lib, ... }:
with lib;
let
  cfg = config.extra.torrent;
in
{
  config.services.rtorrent = mkIf (cfg.enable && !cfg.containered && cfg.rtorrent) (
    with cfg;
    # if cfg.containered then
    #   { }
    # else
    {
      inherit downloadDir;
      enable = true;
      dataDir = "${dataDir}/rtorrent";
      configText = ''
        # log.add_output = "tracker_debug", "log"
        method.redirect=load.throw,load.normal
        method.redirect=load.start_throw,load.start
        method.insert=d.down.sequential,value|const,0
        method.insert=d.down.sequential.set,value|const,0
      '';
    }
    // (if user == null then { } else { inherit user; })
    // (if group == null then { } else { inherit group; })
  );
}
