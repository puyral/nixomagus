{ ... }:
{
  services.syncthing = {
    guiAddress = "0.0.0.0:8384";
    settings.folders = {
      "Logseq" = {
        id = "imwyj-ppta7";
        path = "/home/simon/Documents/Logseq";
        devices = [
          "dynas"
          "MacPro"
          "BV9800"
          # "i7-linux"
          "nixomagus"
        ];
        syncXattrs = true;
      };
      "Hand Notes" = {
        id = "igvtz-mfsxj";
        path = "/home/simon/Documents/Hand Notes";
        devices = [
          "dynas"
          "MacPro"
          "mydos"
          "nixomagus"
        ];
        syncXattrs = true;
      };
    };
  };
}
