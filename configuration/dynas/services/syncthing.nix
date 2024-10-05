{ config, ... }:
{
  extra.extraGroups.photos = {
    members = [ "syncthing" ];
  };

  services.syncthing = {
    guiAddress = "0.0.0.0:8384";
  };
}
