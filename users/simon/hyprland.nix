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
      bind = map mbind ([
        [alt "T" exec "alacritty"]
        [mod "T" exec "alacritty"]
        [mod "K" exec "kitty"]
        [mod "E" "exit"]
        [mod "Q" "killactive"]
        [mod "D" exec "wofi --show run --height=984 --style=\$HOME/.config/wofi.css --term=footclient --prompt=Run"]
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

      # misc = {
      #   disable_hyprland_logo = false;
      # };

    };

    xwayland.enable = true;

  };
}
