{ config, ... }:
let
  photos = "${config.vars.Zeno.mountPoint}/media/photos/exports/complete";
  videos = "${config.vars.Zeno.mountPoint}/media/photos/video_clips";
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
