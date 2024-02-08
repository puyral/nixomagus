{ config, pkgs, ... }:
{
  imports = [ ./wallpapers.nix ];

  home.packages = with pkgs; [
    wofi
  ];

  home.file."config/wofi.css".source = ./wofi.css;

  wayland.windowManager.hyprland = {
    enable = true;
    # enableNvidiaPatches = true;


    settings = let 
      mod = "Super";
      alt = "Alt";
      shift = "SHIFT";

      mbind = builtins.concatStringsSep ",";
      exec = "exec";
    in {

      monitor = 
      map (builtins.concatStringsSep ",") [
        ["HDMI-A-2" "3840x2160" "1280x0" "1" "bitdepth" "10"]
        ["eDP-1" "1920x1080" "5120x800" "1"]
        ["DP-2" "1280x1024" "0x0" "1"]
      ];

      exec-once = [
        "wpaperd"
      ];

      bindm = map mbind [
        [mod "mouse:272" "movewindow"]
        [mod "mouse:273" "resizewindow"]
      ];

      bind = map mbind ([
        [alt "T" exec "alacritty"]
        [mod "T" exec "alacritty"]
        [mod "K" exec "kitty"]
        [mod "E" "exit"]
        [mod "Q" "killactive"]
        # [mod "D" exec "wofi --show run --height=984 --style=\$HOME/.config/wofi.css --term=footclient --prompt=Run"]
        [mod "D" exec "wofi --show run"]
        [mod "Space" exec "wofi --show drun"]

        [mod "F" "fullscreen" "0"]
        [mod "V" "togglefloating" "active" ]

        ["" "XF86AudioRaiseVolume" exec "pamixer -i 5"]
        ["" "XF86AudioLowerVolume" exec "pamixer -d 5"]
      ]

      ++ (
        # workspaces
        # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
        builtins.concatLists (builtins.genList
          (
            x:
            let
              ws =
                let
                  c = (x + 1) / 10;
                in
                builtins.toString (x + 1 - (c * 10));
            in
            [
              [mod ws "workspace" (toString (x + 1))]
              [(mod + shift) ws "movetoworkspace" (toString (x + 1))]
            ]
          )
          10)
      ));

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
      ];


      input.sensitivity = 1;
      # general = {

      #   gaps_in = 6;
      #   gaps_out = 12;
      #   border_size = 4;
      #   col = {
      #     active_border = "0xffb072d1";
      #     inactive_border = "0xff292a37";
      #   };

      # };

      # decoration = {
      #   rounding = 8;
      #   blur = 0;
      #   drop_shadow = 0;
      #   shadow_range = 60;
      #   col.shadow = "0x66000000";
      # };

      # animations = {
      #   enabled = 1;
      #   animation = [
      #     "windows,1,4,default,slide"
      #     "borders,1,5,default"
      #     "fadein,1,5,default"
      #     "workspaces,1,3,default,vertslide"
      #   ];
      # };

      misc = {
        disable_hyprland_logo = true;
        fore_defautl_wallpaper = 0;
      };

    };

    xwayland.enable = true;

  };
}
