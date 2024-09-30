{ ... }:
{
  services.syncthing = {
    settings.folders = {
      "photos" = {
        id = "p6awe-zndxp";
        path = "/Volumes/Zeno/media/photos";
        devices = [ "dynas" ];
        syncXattrs = true;
      };
      "Administratif" = {
        id = "gpvo3-aqakk";
        path = "/home/simon/Documents/Administratif";
        devices = [
          "dynas"
          "MacPro"
          "BV9800"
          # "i7-linux"
        ];
        syncXattrs = true;
      };
      "codage" = {
        id = "7rvge-hjwsl";
        path = "/home/simon/Documents/codage";
        devices = [
          "dynas"
          "MacPro"
        ];
        syncXattrs = true;
      };
      "TU-Wien" = {
        id = "ntazz-iahzt";
        path = "/home/simon/Documents/work/TU-Wien";
        devices = [
          "dynas"
          "MacPro"
        ];
        syncXattrs = true;
      };
      "Logseq" = {
        id = "imwyj-ppta7";
        path = "/home/simon/Documents/Logseq";
        devices = [
          "dynas"
          "MacPro"
          "BV9800"
          "i7-linux"
        ];
        syncXattrs = true;
      };
      "darktable-database" = {
        id = "zuebf-k5yax";
        path = "/home/simon/.config/synced-darktable-database";
        devices = [
          "dynas"
          "MacPro"
        ];
        syncXattrs = true;
      };
    };
  };
}
