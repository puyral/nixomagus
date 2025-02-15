{ lib, config, ... }:
with lib;
let
  cfg = config.extra.torrent;
in
{
  imports = [
    ./rtorrent.nix
    ./ui.nix
    ./transmision.nix
  ];

  options.extra.torrent = {
    enable = mkEnableOption "torrent client";
    downloadDir = mkOption {
      type = types.path;
      default = "/dev/null";
    };
    dataDir = mkOption {
      type = types.path;
      default = "/containers/torrent";
    };
    user = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    group = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    containered = mkOption {
      description = "as a container";
      type = types.bool;
      default = false;
    };
    rtorrent = mkEnableOption "rtorrent";
    transmission = mkEnableOption "transmission";
  };
  config = {
    assertions = [
      {
        assertion = cfg.enable -> cfg.transmission || cfg.rtorrent;
        message = "you need to enable either transission or rtorrent";
      }
    ];
  };
}
