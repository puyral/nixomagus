{ config, pkgs, ... }: {
  imports = [ ];

  programs.wpaperd = {
    enable = true;
    settings = {
      default = {
        path = "/Volumes/Zeno/media/photos/wallpaper";
        duration = "120s";
        sorting = "random";
      };
    };
  };
}
