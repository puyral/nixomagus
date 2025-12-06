{ lib, config, ... }:
with lib;
{
  options.extra.immich = {
    enable = mkEnableOption "immich";
    dataDir = mkOption {
      type = types.path;
      default = "${config.params.locations.containers}/immich";
    };
    subdomain = mkOption {
      type = types.str;
    };
    providers = mkOption {
      type = with types; listOf str;
      example = [ "ovh-pl" ];
    };
    photos = mkOption {
      type = types.path;
      example = "/mnt/Zeno/media/photos/exports/complete";
    };
    library = mkOption {
      type = types.path;
      example = "/mnt/Zeno/media/photos/immich";
    };
    videos = mkOption {
      type = types.path;
      example = "/mnt/Zeno/media/photos/video_clips";
    };
  };
}
