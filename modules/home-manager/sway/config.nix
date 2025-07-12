# sway.nix
{
  lib,
  config,
  pkgs,
  ...
}:

let
  # Modifier keys
  mod = "Mod4"; # Super key
  alt = "Mod1"; # Alt key

  # Terminal
  terminal = "alacritty";

  wrksp =
    let
      convert = i: if i == 0 then "10" else builtins.toString i;
      workspaces = (with builtins; (genList (i: convert i) 10) ++ (genList (i: "e${convert i}") 10));
    in
    i: builtins.elemAt workspaces i;
  cfg = config.extra.sway;

  concatAttrs = builtins.foldl' (acc: x: acc // x) { };

in
{
  config = lib.mkIf cfg.enable {
    wayland.windowManager.sway = {
      checkConfig = false;
      config = rec {
        inherit terminal;
        modifier = mod;

        # see man 5 sway-input
        input = {
          "*" = {
            xkb_options = "compose:menu";
            xkb_layout = "custom";
            xkb_numlock = "enabled";
          };
        };

        # Font for window titles
        fonts = {
          names = [ "pango:Hack" ];
          size = "10";
        };

        # Gaps
        gaps = {
          inner = 5;
          outer = 3;
        };

        # see man sway-output
        output = {
          "DP-3" = {
            res = "3840x2160";
            pos = "1280 0";
            scale = "1";
            adaptive_sync = "on";
            render_bit_depth = "10";
          };
          "HDMI-A-1" = {
            res = "1280x1024";
            pos = "0 0";
            scale = "1";
          };
        };

        # Colors
        colors = {
          focused = {
            background = "#ffffff";
            border = "#ffffff";
            childBorder = "#ffffff";
            indicator = "#ffffff";
            text = "#121314";
          };
          focusedInactive = {
            background = "#121314";
            border = "#121314";
            childBorder = "#121314";
            indicator = "#121314";
            text = "#ffffff";
          };
          unfocused = {
            background = "#121314";
            border = "#121314";
            childBorder = "#121314";
            indicator = "#121314";
            text = "#ffffff";
          };
          urgent = {
            background = "#121314";
            border = "#121314";
            childBorder = "#121314";
            indicator = "#121314";
            text = "#ffffff";
          };
        };

        # Keybindings
        keybindings = # lib.mkOptionDefault
          (
            let
              launchers = {
                "${mod}+Shift+asterisk" = "exec ${terminal} --class 'full-Alacritty'";
                "${mod}+asterisk" = "exec ${terminal}";
                "${mod}+y" = "exec ${terminal}";
                "XF86HomePage+Shift" = "exec ${terminal} --class 'full-Alacritty'";
                "XF86HomePage" = "exec ${terminal}";
                "${mod}+n" = "exec nautilus";
                "${mod}+Return" = "exec wofi --show drun";
                "${mod}+D" = "exec wofi --show drun";
                "${mod}+shift+Return" = "exec wofi --show run";
                "${mod}+shift+D" = "exec wofi --show run";
                "Print" = "exec flameshot gui";
                "${mod}+c" = "exec ${terminal} -o initial_window_width=656 --command zsh -c 'r sage'";
                "XF86Calculator" = "exec ${terminal} -o initial_window_width=656 --command zsh -c 'r sage'";
              };

              window_management = {
                "${mod}+q" = "kill";
                "${mod}+Delete" = "kill";
                "${mod}+h" = "focus left";
                "${mod}+j" = "focus down";
                "${mod}+k" = "focus up";
                "${mod}+l" = "focus right";
                "${mod}+Left" = "focus left";
                "${mod}+Down" = "focus down";
                "${mod}+Up" = "focus up";
                "${mod}+Right" = "focus right";
                "${mod}+Shift+h" = "move left";
                "${mod}+Shift+j" = "move down";
                "${mod}+Shift+k" = "move up";
                "${mod}+Shift+l" = "move right";
                "${mod}+Shift+Left" = "move left";
                "${mod}+Shift+Down" = "move down";
                "${mod}+Shift+Up" = "move up";
                "${mod}+Shift+Right" = "move right";
                "${mod}+${alt}+h" = "split h";
                "${mod}+${alt}+v" = "split v";
                "${mod}+f" = "fullscreen toggle";
                "${mod}+s" = "layout stacking";
                "${mod}+w" = "layout tabbed";
                "${mod}+t" = "layout toggle";
                "${mod}+Shift+space" = "floating toggle";
                "${mod}+space" = "focus mode_toggle";
                "${mod}+a" = "focus parent";
                "${mod}+x" = "[urgent=latest] focus";
                # "${mod}+b" =
                #   "exec wmfocus --textcolor '#131314' --textcolorcurrent '#cc342b' --bgcolor '#ffffff' --bgcolorcurrent '#ffffff' --font 'Hack-Mono:100'";
              };

              reload_restart_exit = {
                "${mod}+Shift+c" = "reload";
                "${mod}+Shift+r" = "restart";
                "${mod}+Shift+Delete" =
                  "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -B 'Yes, exit sway' 'swaymsg exit'";
              };

              resize_mode = {
                "${mod}+r" = "mode resize";
              };

              media_control = {
                "XF86AudioRaiseVolume" = "exec wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+";
                "${alt}+XF86AudioRaiseVolume" = "exec wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 100%";
                "XF86AudioLowerVolume" = "exec wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-";
                "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
                "XF86AudioMicMute" = "exec pulseaudio-ctl mute-input"; # Note: this might need adjustment for pipewire
                "XF86AudioPlay" = "exec playerctl play-pause";
                "XF86AudioNext" = "exec playerctl next";
                "XF86AudioPrev" = "exec playerctl previous";
                "XF86Tools" = "exec ${terminal} --command sh -c 'ncmpcpp'";
                "Shift+XF86AudioRaiseVolume" = "exec mpc volume +5";
                "${alt}+Shift+XF86AudioRaiseVolume" = "exec mpc volume 100";
                "Shift+XF86AudioLowerVolume" = "exec mpc volume -5";
                # Media mode
                "${mod}+m" = "mode media";
              };

              workspaces =
                with lib;
                (
                  let
                    n = 10;
                    count = genList (i: i) n;
                    lower_map = i: {
                      "${mod}+${toString i}" = "workspace ${wrksp i}";
                      "${mod}+Shift+${toString i}" = "move container to workspace ${wrksp i}";
                    };
                    extra_map = i: {
                      "${mod}+Control+${toString i}" = "workspace ${wrksp (i + n)}";
                      "${mod}+Control+Shift+${toString i}" = "move container to workspace ${wrksp (i + n)}";
                    };
                    bindings = (map lower_map count) ++ (map extra_map count);
                  in
                  concatAttrs bindings
                );

              sections = [
                launchers
                window_management
                reload_restart_exit
                resize_mode
                media_control
                workspaces
              ];

            in
            concatAttrs sections
          );
        workspaceAutoBackAndForth = true;

        # Workspace keybindings
        workspaceOutputAssign = [
          {
            workspace = wrksp 1; # workspaces."1";
            output = "DP-3";
          }
          {
            workspace = wrksp 17;
            output = "HDMI-A-1";
          } # Please verify this output name
          # { workspace = workspaces."20"; output = "DP-1"; } # Please verify this output name
        ];

        # Modes
        modes = {
          resize = {
            "h" = "resize shrink width 5 px or 5 ppt";
            "j" = "resize grow height 5 px or 5 ppt";
            "k" = "resize shrink height 5 px or 5 ppt";
            "l" = "resize grow width 5 px or 5 ppt"; # Corrected from 'k'
            "Shift+h" = "resize shrink width 1 px or 1 ppt";
            "Shift+j" = "resize grow height 1 px or 1 ppt";
            "Shift+k" = "resize shrink height 1 px or 1 ppt";
            "Shift+l" = "resize grow width 1 px or 1 ppt"; # Added for consistency
            "Left" = "resize shrink width 5 px or 5 ppt";
            "Down" = "resize grow height 5 px or 5 ppt";
            "Up" = "resize shrink height 5 px or 5 ppt";
            "Right" = "resize grow width 5 px or 5 ppt";
            "Shift+Left" = "resize shrink width 1 px or 1 ppt";
            "Shift+Down" = "resize grow height 1 px or 1 ppt";
            "Shift+Up" = "resize shrink height 1 px or 1 ppt";
            "Shift+Right" = "resize grow width 1 px or 1 ppt";
            "Return" = "mode default";
            "Escape" = "mode default";
            "${mod}+r" = "mode default";
          };
          media = {
            "Up" = "exec wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+";
            "Down" = "exec wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-";
            "Right" = "exec playerctl next";
            "Left" = "exec playerctl previous";
            "Shift+Up" = "exec mpc volume +5";
            "Shift+Down" = "exec mpc volume -5";
            "${alt}+Up" = "exec wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 100%";
            "space" = "exec playerctl play-pause";
            "Return" = "mode default";
            "Escape" = "mode default";
            # "${mod}+m" = "exec ${terminal} --class 'ncmpcpp' --command sh -c 'ncmpcpp'; mode default";
            # "${mod}+Shift+m" = "exec ${terminal} --command sh -c 'ncmpcpp'; mode default";
            "${mod}+s" = "exec spotify; mode default";
          };
        };

        # Startup commands
        startup = [
          {
            command = "systemctl --user start wallpaper.target";
            always = true;
          }
          # {
          #   command = "solaar --window=hide";
          #   always = true;
          # }
          # {
          #   command = "mpd-mpris";
          #   always = true;
          # }
          # {
          #   command = "numlockx";
          #   always = true;
          # }
          {
            command = "dunst -conf ~/.config/dunst/dunstrc";
          }
          # {
          #   command = "unclutter";
          #   always = true;
          # }
          {
            command = "swaymsg 'workspace ${wrksp 17}; exec thunderbird'";
          }
          {
            command = "swaymsg 'workspace ${wrksp 18}; exec pavucontrol'";
          }
          # { command = "swaymsg 'workspace ${workspaces."10"}; exec alacritty --class \"ncmpcpp-auto\" -e \"ncmpcpp\"'"; always = true; }
          {
            command = "swaymsg 'workspace ${wrksp 1}; exec firefox'";
          }
        ];

        floating = {
          modifier = alt;
          # Floating window rules
          criteria = [
            {
              class = "matplotlib";
            }
            {
              class = "Alacritty";
            }
            # {
            #     class = "full-Alacritty";
            # }
            {
              title = "^zoom$";
              class = "[zoom]*";
            }
          ];
        };

        # Bar configuration
        # bars = [
        #   {
        #     command = "waybar"; # i3status is an option, but waybar is more common with sway
        #     stripWorkspaceNumbers = true;
        #     trayOutput = "primary";
        #   }
        # ];

        # wrapperFeatures = {
        #   # Enable support for xwayland so you can run X11 apps
        #   xwayland = true;
        # };
      };

      # Extra config for things not covered by the module
      extraConfig = ''
        # You can put things here that are not directly supported by the home-manager module
        # For example, complex workspace assignments or specific input device settings.
        bindsym ${mod}+Control+Shift+Left move workspace to output left
        bindsym ${mod}+Control+Shift+Right move workspace to output right
        bindsym ${mod}+Control+Shift+Up move workspace to output up
        bindsym ${mod}+Control+Shift+Down move workspace to output down
        bindsym ${mod}+Control+Left workspace prev
        bindsym ${mod}+Control+Right workspace next
      '';

    };
  };
}
