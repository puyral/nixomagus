{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.extra.torrent;
in
{
  config = mkIf (cfg.enable && !cfg.containered && cfg.rtorrent) {

    services.rtorrent =
      with cfg;
      (
        {
          inherit downloadDir;
          enable = true;
          dataDir = "${dataDir}/rtorrent";
          package = pkgs.rtorrent.override {
            libtorrent-rakshasa = pkgs.libtorrent-rakshasa.overrideAttrs (oldAttrs: {
              postPatch = (oldAttrs.postPatch or "") + ''
                substituteInPlace src/net/curl_socket.cc \
                  --replace-fail 'CurlSocket::event_read() {' 'CurlSocket::event_read() {
  char buffer[64];
  while (::read(m_fileDesc, buffer, sizeof(buffer)) > 0) {}'
              '';
            });
          };
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
    # FIX: Increase open file limit for the service
    systemd.services.rtorrent = {
      serviceConfig = {
        LimitNOFILE = 65536;
      };
    };

  };
}
