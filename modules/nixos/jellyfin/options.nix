{ lib, config, ... }:
with lib;
{
  options.extra.jellyfin = {
    enable = mkEnableOption "jellyfin";
    dataDir = mkOption {
      type = types.path;
      default = "${config.params.locations.containers}/jellyfin";
    };
    videoDir = mkOption {
      type = types.path;
      default = "${config.vars.Zeno.mountPoint}/media/videos";
    };
  };
}
