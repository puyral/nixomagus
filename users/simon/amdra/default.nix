{
  config,
  pkgs,
  system,
  pkgs-unstable,
  overlays,
  mconfig,
  custom,
  ...
}@attrs:
{
  imports = [ ./darktheme.nix ];
  extra = {
    applications.gui.enable = true;
    emacs = {
      enable = true;
      squirrel.enable = true;
    };
    i3 = {
      enable = false;
      xrandr = "--output HDMI-1 --mode 1280x1024 --pos 0x0 --rotate normal --output DP-1 --primary --mode 3840x2160 --pos 1280x0 --rotate normal --output DP-2 --off --output DP-3 --off";
    };
    logseq.enable = true;
    wallpaper.enable = true;
    sway.enable = true;
    mangowc = {
      enable = true;
      monitors = [
        {
          name = "DP-3";
          width = "3840";
          height = "2160";
          x = "1280";
          y = "0";
          refresh = "60";
        }
        {
          name = "HDMI-A-1";
          width = "1280";
          height = "1024";
          x = "0";
          y = "0";
          refresh = "60";
        }
      ];
    };
    hyprland = {
      enable = true;
      monitors = [
        [
          "DP-1"
          "3840x2160"
          "1280x0"
          "1"
          "bitdepth"
          "10"
        ]
        [
          "HDMI-A-1"
          "1280x1024"
          "0x0"
          "1"
        ]
      ];
    };
    darktable = {
      library = "/home/simon/.config/synced-darktable-database/library.db";
      export = {
        jpgsDir = "/Volumes/Zeno/media/photos/full-export/jpegs";
      };
    };
    opencode = {
      enable = true;
      leanSupport.mcp = true;
    };
  };

  home = {

    packages =
      (with custom; [ clocktui ])
      ++ (with pkgs; [
        nvtopPackages.amd
        kitty
        vampire
        hugin
      ])
      ++ (with pkgs-unstable; [ fastfetch ]);
  };
}
