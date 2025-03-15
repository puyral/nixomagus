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
  config = {
    #         intel-gpu-tools

    extra = {
      applications.gui.enable = true;
      i3 = {
        enable = true;
        xrandr =
          if mconfig.is_docked then
            "--output HDMI-0 --primary --mode 3840x2160 --pos 1280x0 --rotate normal --output DP-0 --mode 1280x1024 --pos 0x0 --rotate normal --output DP-1 --off --output eDP-1-1 --mode 1920x1080 --pos 5120x903 --rotate normal --output DP-1-1 --off --output HDMI-1-1 --off"
          else
            "--output eDP-1-1 --mode 1920x1080 --rotate normal --output DP-1-1 --off --output HDMI-1-1 --off";

      };
      logseq.enable = true;
      wallpaper.enable = true;
    };

    home = {

      packages =
        (with custom; [ clocktui ])
        ++ (with pkgs; [
          intel-gpu-tools
          # nvtopPackages.full
        ]);

    };
  };
}
