# sway.nix
{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.extra.sway;

  # Modifier keys
  mod = "Mod4"; # Super key
  alt = "Mod1"; # Alt key

  # Terminal
  terminal = "alacritty --class=${alacritty_float_class}";
  full_terminal = "alacritty";
  alacritty_float_class = "alacritty_float";

  boder_width = 2;

  concatAttrs = builtins.foldl' (acc: x: acc // x) { };
  wrksp =
    let
      convert = i: if i == 0 then "10" else builtins.toString i;
      workspaces = (with builtins; (genList (i: convert i) 10) ++ (genList (i: "e${convert i}") 10));
    in
    i: builtins.elemAt workspaces i;
  vim_motions = f: (f "Left" "Down" "Up" "Right") // (f "h" "j" "k" "l");

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
          size = "13";
        };

        # Gaps
        gaps = {
          inner = 5;
          outer = 8;
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
          # urgent = {
          #   background = "#121314";
          #   border = "#FF0000";
          #   childBorder = "#121314";
          #   indicator = "#121314";
          #   text = "#ffffff";
          # };
        };

        # Keybindings
        keybindings = # lib.mkOptionDefault
          (
            let
              launchers = {
                "${mod}+Shift+asterisk" = "exec ${full_terminal}";
                "${mod}+asterisk" = "exec ${terminal}";
                "${mod}+Return" = "exec ${terminal}";
                "${mod}+Shift+Return" = "exec ${full_terminal}";
                "XF86HomePage+Shift" = "exec ${full_terminal}";
                "XF86HomePage" = "exec ${terminal}";

                "${mod}+Space" = "exec wofi --show drun";
                "${mod}+D" = "exec wofi --show drun";
                "${mod}+Shift+Space" = "exec wofi --show run";
                "${mod}+Shift+D" = "exec wofi --show run";

                "${mod}+n" = "exec nautilus";
                "Print" = "exec flameshot gui";
                "${mod}+c" = "exec ${terminal} -o initial_window_width=656 --command zsh -c 'r sage'";
                "XF86Calculator" = "exec ${terminal} -o initial_window_width=656 --command zsh -c 'r sage'";
              };

              window_movement = vim_motions (
                l: d: u: r: {
                  "${mod}+${l}" = "focus left";
                  "${mod}+${d}" = "focus down";
                  "${mod}+${u}" = "focus up";
                  "${mod}+${r}" = "focus right";
                  "${mod}+Shift+${l}" = "move left";
                  "${mod}+Shift+${d}" = "move down";
                  "${mod}+Shift+${u}" = "move up";
                  "${mod}+Shift+${r}" = "move right";
                }
              );

              window_management = {
                "${mod}+q" = "kill";
                "${mod}+Delete" = "kill";
                "${mod}+${alt}+h" = "split h";
                "${mod}+${alt}+v" = "split v";
                "${mod}+f" = "fullscreen toggle";
                "${mod}+s" = "layout stacking";
                "${mod}+w" = "layout tabbed";
                "${mod}+t" = "layout toggle";
                "${mod}+Shift+v" = "floating toggle";
                "${mod}+v" = "focus mode_toggle";
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
              workspace_manipulation = vim_motions (
                l: d: u: r: {
                  "${mod}+Control+Shift+${l}" = "move workspace to output left";
                  "${mod}+Control+Shift+${r}" = "move workspace to output right";
                  "${mod}+Control+Shift+${u}" = "move workspace to output up";
                  "${mod}+Control+Shift+${d}" = "move workspace to output down";
                  "${mod}+Control+${l}" = "workspace prev";
                  "${mod}+Control+${r}" = "workspace next";
                }
              );

              sections = [
                launchers
                window_movement
                window_management
                reload_restart_exit
                resize_mode
                media_control
                workspaces
                workspace_manipulation
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
        modes =
          let
            leave = {
              "Return" = "mode default";
              "Escape" = "mode default";
            };
          in
          {
            resize =
              vim_motions (
                l: d: u: r: {
                  "${l}" = "resize shrink width 5 px or 5 ppt";
                  "${d}" = "resize shrink height 5 px or 5 ppt";
                  "${u}" = "resize grow height 5 px or 5 ppt";
                  "${r}" = "resize grow width 5 px or 5 ppt";
                  "Shift+${l}" = "resize shrink width 1 px or 1 ppt";
                  "Shift+${d}" = "resize shrink height 1 px or 1 ppt";
                  "Shift+${u}" = "resize grow height 1 px or 1 ppt";
                  "Shift+${r}" = "resize grow width 1 px or 1 ppt";
                }
              )
              // leave
              // {
                "${mod}+r" = "mode default";
              };
            media =
              vim_motions (
                l: d: u: r: {
                  "${u}" = "exec wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+";
                  "${d}" = "exec wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-";
                  "${r}" = "exec playerctl next";
                  "${l}" = "exec playerctl previous";
                  "Shift+${u}" = "exec mpc volume +5";
                  "Shift+${d}" = "exec mpc volume -5";
                  "${alt}+${u}" = "exec wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 100%";
                }
              )
              // {
                "space" = "exec playerctl play-pause";
                # "${mod}+m" = "exec ${terminal} --class 'ncmpcpp' --command sh -c 'ncmpcpp'; mode default";
                # "${mod}+Shift+m" = "exec ${terminal} --command sh -c 'ncmpcpp'; mode default";
                "${mod}+s" = "exec spotify; mode default";
              }
              // leave;
          };

        # Startup commands
        startup = [
          {
            command = "systemctl --user start wallpaper.target";
            always = true;
          }
          {
            command = "dunst -conf ~/.config/dunst/dunstrc";
          }
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

        window = {
          # border = boder_width;
          titlebar = false;
        };

        floating = {
          modifier = alt;
          # border = "pixel 2";
          # Floating window rules
          criteria = [
            {
              class = "matplotlib";
            }
            {
              app_id = "${alacritty_float_class}";
            }
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
        bars = [
          {
            inherit fonts;
            mode = "dock";
            position = "bottom";
            statusCommand = config.vars.swayBarStatusCommand;
            trayOutput = "primiary";
            workspaceButtons = true;
            workspaceNumbers = false;
          }
        ];
      };

      # Extra config for things not covered by the module
      extraConfig = ''
        # You can put things here that are not directly supported by the home-manager module
        # For example, complex workspace assignments or specific input device settings.
        shadows enable
        shadow_blur_radius 20
        shadow_color #000000FF
        shadow_inactive_color #00000050
        # corner_radius 5

        default_border pixel 2
        default_floating_border pixel 2
      '';

    };
  };
}
