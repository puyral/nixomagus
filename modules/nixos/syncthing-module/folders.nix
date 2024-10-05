{ ... }:
{
  extra.syncthing.folders = {

    "photos" = {
      id = "p6awe-zndxp";
      devices = {
        nixomagus = {
          path = "/Volumes/Zeno/media/photos";
        };
        dynas = {
          path = "/mnt/Zeno/media/photos";
        };
      };
    };

    "Administratif" = {
      id = "gpvo3-aqakk";
      devices = {
        nixomagus = {
          path = "/home/simon/Documents/Administratif";
        };
        dynas = {
          path = "/mnt/Zeno/administratif";
        };
      };
      extraDevices = [
        "MacPro"
        "BV9800"
      ];
    };

    "codage" = {
      id = "7rvge-hjwsl";
      devices = {
        nixomagus = {
          path = "/home/simon/Documents/codage";
        };
        dynas = {
          path = "/mnt/Zeno/work/other/codage";
        };
      };
      extraDevices = [ "MacPro" ];
    };

    "TU-Wien" = {
      id = "ntazz-iahzt";
      devices = {
        nixomagus = {
          path = "/home/simon/Documents/work/TU-Wien";
        };
        dynas = {
          path = "/mnt/Zeno/work/TU-Wien";
        };
      };
      extraDevices = [ "MacPro" ];
    };

    "Logseq" = {
      id = "imwyj-ppta7";
      devices = {
        nixomagus = {
          path = "/home/simon/Documents/Logseq";
        };
        mydos = {
          path = "/home/simon/Documents/Logseq";
        };
        "i7" = {
          path = "/home/simon/Documents/Logseq";
        };
        dynas = {
          path = "/mnt/Zeno/work/Logseq";
        };
      };
      extraDevices = [
        "MacPro"
        "BV9800"
      ];
    };

    "Hand Notes" = {
      id = "igvtz-mfsxj";
      devices = {
        nixomagus = {
          path = "/home/simon/Documents/Hand Notes";
        };
        mydos = {
          path = "/home/simon/Documents/Hand Notes";
        };
        "i7" = {
          path = "/home/simon/Documents/Hand Notes";
        };
        dynas = {
          path = "/mnt/Zeno/work/Hand Notes";
        };
      };
      extraDevices = [ "MacPro" ];
    };

    "darktable-database" = {
      id = "zuebf-k5yax";
      devices = {
        nixomagus = {
          path = "/home/simon/.config/synced-darktable-database";
        };
        dynas = {
          path = "/mnt/Zeno/media/darktable-database";
        };
      };
      extraDevices = [ "MacPro" ];
    };

    "Wallpapers" = {
      id = "iwgas-ogb6p";
      devices = {
        mydos = {
          path = "/home/simon/Pictures/Wallpapers";
        };
        dynas = {
          path = "/mnt/Zeno/media/Wallpapers";
        };
        nixomagus = {
          path = "/home/simon/Pictures/Wallpapers";
        };
        "i7" = {
          path = "/home/simon/Pictures/Wallpapers";
        };
      };
      extraDevices = [ "MacPro" ];
    };
  };
}
