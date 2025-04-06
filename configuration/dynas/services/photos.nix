{ ... }:
let
  photos = "/mnt/Zeno/media/photos/exports/complete";
  videos = "/mnt/Zeno/media/photos/video_clips";
  providers = [ "ovh-pl" ];
in
{
  extra = {
    immich = {
      enable = true;
      subdomain = "immich";
      inherit photos providers;
    };
    photoprism = {
      enable = true;
      subdomain = "photos";
      inherit photos providers videos;
    };
  };
}
