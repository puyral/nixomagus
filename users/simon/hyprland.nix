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

  home.packages = with pkgs; [ wofi ];

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
    in {

      exec-once = [ "args -b hypr" "wpaperd" ];

      monitor = map (builtins.concatStringsSep ",") [
        [ "HDMI-A-2" "3840x2160" "1280x0" "1.25" "bitdepth" "10" ]
        [ "eDP-1" "1920x1080" "4352x700" "1.25" ]
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
        [ (mod + shift) "D" exec "wofi --show drun" ]
        [ mod "Space" exec "wofi --show drun" ]

        [ mod "F" "fullscreen" "0" ]
        [ mod "V" "togglefloating" "active" ]

        [ "" "XF86AudioRaiseVolume" exec "pamixer -i 5" ]
        [
          ""
          "XF86AudioLowerVolume"
          exec
          "pamixer -d 5"
        ]

        # move window
        [ (mod + shift) "left" "movewindow" "l" ]
        [ (mod + shift) "right" "movewindow" "r" ]
        [ (mod + shift) "up" "movewindow" "u" ]
        [
          (mod + shift)
          "down"
          "movewindow"
          "d"
        ]

        # move focus
        [ mod "left" "movefocus" "l" ]
        [ mod "right" "movefocus" "r" ]
        [ mod "up" "movefocus" "u" ]
        [
          mod
          "down"
          "movefocus"
          "d"
        ]

        # move workspace between monitors
        [ (mod + ctrl) "left" "movecurrentworkspacetomonitor" "l" ]
        [ (mod + ctrl) "right" "movecurrentworkspacetomonitor" "r" ]

        [ mod tab "cyclenext" ]
      ]

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
