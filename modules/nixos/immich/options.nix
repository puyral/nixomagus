{ lib, ... }:
with lib;
{
  options.extra.immich = {
    enable = mkEnableOption "immich";
    dataDir = mkOption {
      type = types.path;
      default = "/containers/immich";
    };
  };
}
