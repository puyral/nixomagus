{ config, ... }:
let
  photos = "${config.vars.Zeno.mountPoint}/media/photos/full-export/jpegs";
  videos = "${config.vars.Zeno.mountPoint}/media/photos/full-export/videos";
  providers = [
    "ovh-pl"
    "dynas"
  ];
in
{
  extra = {
    immich = {
      enable = true;
      subdomain = "immich";
      inherit photos providers videos;
    };
    photoprism = {
      enable = true;
      subdomain = "photos";
      inherit photos providers videos;
    };
  };
}
