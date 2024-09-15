{ ... }:
{

  services.syncthing = {
    settings.folders = {
      "photos" = {
        id = "p6awe-zndxp";
        path = "/Volumes/Zeno/media/photos";
        devices = [ "dynas" ];
      };
      "Administratif" = {
        id = "gpvo3-aqakk";
        path = "/home/simon/Documents/Administratif";
        devices = [
          "dynas"
          "MacPro"
          "BV9800"
          "i7-linux"
        ];
      };
      "codage" = {
        id = "7rvge-hjwsl";
        path = "/home/simon/Documents/codage";
        devices = [
          "dynas"
          "MacPro"
        ];
      };
      "TU-Wien" = {
        id = "ntazz-iahzt";
        path = "/home/simon/Documents/work/TU-Wien";
        devices = [
          "dynas"
          "MacPro"
        ];
      };
      "Logseq" = {
        id = "imwyj-ppta7";
        path = "/home/simon/Documents/Logseq";
        devices = [
          "dynas"
          "MacPro"
          "BV9800"
        ];
      };
      "darktable-database" = {
        id = "zuebf-k5yax";
        path = "/home/simon/.config/synced-darktable-database";
        devices = [
          "dynas"
          "MacPro"
        ];
      };
    };
  };
}
