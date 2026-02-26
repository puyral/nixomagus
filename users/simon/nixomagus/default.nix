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
  config =
    let
      is_docked = config.osConfig.extra.gui.is_docked or true;

    in
    {
      #         intel-gpu-tools

      extra = {
        applications.gui.enable = true;
        i3 = {
          enable = true;
          xrandr =
            if is_docked then
              "--output HDMI-0 --primary --mode 3840x2160 --pos 1280x0 --rotate normal --output DP-0 --mode 1280x1024 --pos 0x0 --rotate normal --output DP-1 --off --output eDP-1-1 --mode 1920x1080 --pos 5120x903 --rotate normal --output DP-1-1 --off --output HDMI-1-1 --off"
            else
              "--output eDP-1-1 --mode 1920x1080 --rotate normal --output DP-1-1 --off --output HDMI-1-1 --off";

        };
        logseq.enable = true;
        wallpaper.enable = true;
        hyprland = {
          monitors = (
            if is_docked then
              [
                [
                  "HDMI-A-2"
                  "3840x2160"
                  "1280x0"
                  "1"
                  "bitdepth"
                  "10"
                ]
                [
                  "eDP-1"
                  "disable"
                ]
                [
                  "DP-2"
                  "1280x1024"
                  "0x0"
                  "1"
                ]
              ]
            else

              [
                [
                  "eDP-1"
                  "1920x1080"
                  "0x0"
                  "1"
                ]
              ]
          );
          extraSettings = {
            # nvidia
            env = [
              "LIBVA_DRIVER_NAME,nvidia"
              "XDG_SESSION_TYPE,wayland"
              "GBM_BACKEND,nvidia-drm"
              "__GLX_VENDOR_LIBRARY_NAME,nvidia"
              "WLR_NO_HARDWARE_CURSORS,1"

              # https://www.reddit.com/r/hyprland/comments/17tfwfo/checking_if_nvidia_primerun_is_working/
              "__NV_PRIME_RENDER_OFFLOAD,1"
              "__VK_LAYER_NV_optimus,NVIDIA_only"
              "NVD_BACKEND,direct"
              "NIXOS_OZONE_WL,1"

              # choose GPU
              "WLR_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1"
            ];
          };
        };
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
