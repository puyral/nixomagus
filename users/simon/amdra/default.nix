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
    i3 = {
      enable = false;
      xrandr = "--output HDMI-1 --mode 1280x1024 --pos 0x0 --rotate normal --output DP-1 --primary --mode 3840x2160 --pos 1280x0 --rotate normal --output DP-2 --off --output DP-3 --off";
    };
    logseq.enable = true;
    wallpaper.enable = true;
    sway.enable = true;
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
    generate-jpgs = {
      enable = true;
      onTimer.enable = false;
      locations = {
        library = "/home/simon/.config/synced-darktable-database/library.db";
        export = "/Volumes/Zeno/media/photos/full-export/jpegs";
      };
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
