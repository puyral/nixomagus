{ lib, config, ... }:
{
  options.extra.photoprism = with lib; {
    enable = mkEnableOption "photoprism";
    dataDir = mkOption {
      type = types.path;
      default = "${config.params.locations.containers}/photoprism";
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
    videos = mkOption {
      type = types.path;
      example = "/mnt/Zeno/media/photos/video_clips";
    };
  };
}
