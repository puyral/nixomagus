{ lib, ... }:
with lib;
{
  imports = [
    ./rtorrent.nix
    ./ui.nix
  ];

  options.extra.torrent = {
    enable = mkEnableOption "torrent clinet";
    downloadDir = mkOption {
      type = types.path;
      default = "/dev/null";
    };
    dataDir = mkOption {
      type = types.path;
      default = "/containers/torrent";
    };
    user = mkOption { type = types.nullOr types.str; };
    group = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    containered = mkOption {
      description = "as a container";
      type = types.bool;
      default = false;
    };
  };
}
