{...} : {
    services.syncthing = {
      "Logseq" = {
        id = "imwyj-ppta7";
        path = "/home/simon/Documents/Logseq";
        devices = [
          "dynas"
          "MacPro"
          "BV9800"
          # "i7-linux"
          "nixomagu"
        ];
        syncXattrs = true;
      };

    };
}