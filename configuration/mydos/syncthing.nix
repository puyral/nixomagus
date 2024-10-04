{ ... }:
{
  services.syncthing = {
    guiAddress = "localhost:8384";
    settings.folders = {
      "Logseq" = {
        id = "imwyj-ppta7";
        path = "/home/simon/Documents/Logseq";
        devices = [
          "dynas"
          "MacPro"
          "BV9800"
          "i7-linux"
          "nixomagus"
        ];
        syncXattrs = true;
      };
      "Wallpapers" = {
        id = "iwgas-ogb6p";
        path = "/home/simon/Pictures/Wallpapers";
        devices = [
          "dynas"
          "MacPro"
          # "BV9800"
          # "i7-linux"
          # "nixomagus"
        ];
        syncXattrs = true;
      };
    };
  };
}
