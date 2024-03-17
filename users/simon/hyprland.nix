{ config, pkgs, ... }:
let
  my-hyprland = pkgs.hyprland;
  launcher = pkgs.writeShellScriptBin "hypr" ''
    #!/${pkgs.bash}/bin/bash
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only

    exec ${my-hyprland}/bin/Hyprland
  '';
in {
  imports = [ ./wallpapers.nix ];

  home.packages = with pkgs; [ wofi xdg-desktop-portal-hyprland ];

  home.file.".config/wofi.css".source = ./wofi.css;

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;
    # enableNvidiaPatches = true;

    settings = let
      mod = "Super";
      alt = "ALT";
      shift = "SHIFT";
      ctrl = "CTRL";
      tab = "TAB";

      mbind = builtins.concatStringsSep ",";
      exec = "exec";

      arrow_keys = {
        l = "left";
        r = "right";
        u = "up";
        d = "down";
      };
      vim_keys = {
        l = "h";
        u = "k";
        d = "j";
        r = "l";
      };
    in {

      exec-once = [ "args -b hypr" "wpaperd" ];

      monitor = map (builtins.concatStringsSep ",") [
        [
          "HDMI-A-2"
          "3840x2160"
          "1280x0"
          "1"
          "bitdepth"
          "10"
        ]
        # [ "eDP-1" "1920x1080" "4352x700" "1.25" ]
        [ "eDP-1" "disable" ]
        [ "DP-2" "1280x1024" "0x0" "1" ]
      ];

      general = { resize_on_border = true; };

      input = {
        follow_mouse = 1;
        # kb_options = "caps:swapescape";
        repeat_rate = 50;
        numlock_by_default = true;
      };

      decoration = {
        drop_shadow = 1;
        shadow_range = 10;
        shadow_render_power = 2;
        # col = {
        # shadow = "0x55000000";
        # shadow_inactive = "0x55000000";
        # };
        rounding = 4;
      };

      # see wev
      bindm = let
        leftclick = "mouse:272";
        rightclick = "mouse:273";
      in map mbind [
        [ mod leftclick "movewindow" ]
        [ mod rightclick "resizewindow" ]
        [ "Alt_R" leftclick "movewindow" ]
        [ "Alt_R" rightclick "resizewindow" ]
      ];

      bind = map mbind ([
        [ alt "T" exec "alacritty" ]
        [ mod "T" exec "alacritty" ]
        [ mod "K" exec "kitty" ]
        [ mod "E" "exit" ]
        [ mod "Q" "killactive" ]
        [
          mod
          "U"
          exec
          "wofi --show drun --height=984 --style=$HOME/.config/wofi.css --term=footclient --prompt=Run"
        ]
        [ mod "D" exec "wofi --show drun" ]
        [ (mod + shift) "D" exec "wofi --show run" ]
        [ mod "Space" exec "wofi --show drun" ]

        [ mod "F" "fullscreen" "0" ]
        [ mod "V" "togglefloating" "active" ]

        [
          mod
          tab
          "cyclenext"
        ]

        # media control
        [
          ""
          "XF86AudioRaiseVolume"
          exec
          "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ]
        [
          ""
          "XF86AudioLowerVolume"
          exec
          "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-"
        ]
        [
          ""
          "XF86AudioMute"
          exec
          "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ]
      ] ++ (let
        mmove = { l, r, u, d }: [
          # move window
          [ (mod + shift) l "movewindow" "l" ]
          [ (mod + shift) r "movewindow" "r" ]
          [ (mod + shift) u "movewindow" "u" ]
          [
            (mod + shift)
            d
            "movewindow"
            "d"
          ]

          # move focus
          [ mod l "movefocus" "l" ]
          [ mod r "movefocus" "r" ]
          [ mod u "movefocus" "u" ]
          [
            mod
            d
            "movefocus"
            "d"
          ]

          # move workspace between monitors
          [ (mod + ctrl) l "movecurrentworkspacetomonitor" "l" ]
          [ (mod + ctrl) r "movecurrentworkspacetomonitor" "r" ]
        ];
      in mmove arrow_keys ++ mmove vim_keys)

        ++ (
          # workspaces
          # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
          builtins.concatLists (builtins.genList (x:
            let
              ws = let c = (x + 1) / 10;
              in builtins.toString (x + 1 - (c * 10));
            in [
              [ mod ws "workspace" (toString (x + 1)) ]
              [ (mod + shift) ws "movetoworkspace" (toString (x + 1)) ]
            ]) 10)));

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

        # choose GPU
        "WLR_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1"
      ];

      misc = {
        disable_hyprland_logo = true;
        force_default_wallpaper = 0;
        disable_autoreload = false;
      };

      xwayland = { force_zero_scaling = true; };

    };

  };
}
