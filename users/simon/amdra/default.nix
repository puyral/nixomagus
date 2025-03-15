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
  extra = {applications.gui = true;
  i3 = {enable =true;
xrandr = "--output HDMI-1 --mode 1280x1024 --pos 0x0 --rotate normal --output DP-1 --mode 3840x2160 --pos 1280x114 --rotate normal --output DP-2 --off --output DP-3 --off";
  };
  logseq.enable =true;
  wallpaper.enable = true;
  };


  home = {

    packages =
      (with custom; [ clocktui ]);

  };
}
