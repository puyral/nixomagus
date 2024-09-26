{ config, ... }:
{
  extra.extraGroups.photos = {
    members = [ "syncthing" ];
  };

  services.syncthing = {
    guiAddress = "0.0.0.0:8384";
    settings.folders = {
      "photos" = {
        id = "p6awe-zndxp";
        path = "/mnt/Zeno/media/photos";
        devices = [ "nixomagus" ];
      };
      "Administratif" = {
        id = "gpvo3-aqakk";
        path = "/mnt/Zeno/administratif";
        devices = [
          "nixomagus"
          "MacPro"
          "BV9800"
          "i7-linux"
        ];
      };
      "TU-Wien" = {
        id = "ntazz-iahzt";
        path = "/mnt/Zeno/work/TU-Wien";
        devices = [
          "nixomagus"
          "MacPro"
        ];
      };
      "darktable-database" = {
        id = "zuebf-k5yax";
        path = "/mnt/Zeno/media/darktable-database";
        devices = [
          "nixomagus"
          "MacPro"
        ];
      };
      "codage" = {
        id = "7rvge-hjwsl";
        path = "/mnt/Zeno/work/other/codage";
        devices = [
          "nixomagus"
          "MacPro"
        ];
      };
    };
  };
}
