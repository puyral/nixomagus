{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.extra.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      pamixer
    ];
    # from https://github.com/HeinzDev/Hyprland-dotfiles
    programs.waybar = {
      enable = true;
      systemd = {
        enable = false;
        target = "graphical-session.target";
      };
      style = builtins.readFile ./style.css;
      settings = [
        {
          "layer" = "top";
          "position" = "top";
          modules-left = [
            # "hyprland/workspaces"
            # "hyprland/window"
              "ext/workspaces"
    "dwl/window"
            # "custom/launcher"
            # "temperature"
            # "mpd"
            # "custom/cava-internal"
          ];
          modules-center = [
            "clock"
          ];
          modules-right = [
            "pulseaudio"
            "memory"
            "cpu"
            "network"
            "tray"
          ];
          # "custom/launcher" = {
          #   "format" = " ";
          #   "on-click" = "pkill rofi || rofi2";
          #   "on-click-middle" = "exec default_wall";
          #   "on-click-right" = "exec wallpaper_random";
          #   "tooltip" = false;
          # };
          # "custom/cava-internal" = {
          #   "exec" = "sleep 1s && cava-internal";
          #   "tooltip" = false;
          # };
          "pulseaudio" = {
            "scroll-step" = 1;
            "format" = "{icon} {volume}%";
            "format-muted" = "󰖁 Muted";
            "format-icons" = {
              "default" = [
                ""
                ""
                ""
              ];
            };
            "on-click" = "pamixer -t";
            "tooltip" = false;
          };
          "clock" = {
            "interval" = 1;
            "format" = "{:%T  %A %b %d}";
            # "tooltip" = true;
            # "tooltip-format" = "{=%A; %d %B %Y}\n<tt>{calendar}</tt>";
          };
          "memory" = {
            "interval" = 1;
            "format" = "󰻠 {percentage}%";
            "states" = {
              "warning" = 85;
            };
          };
          "cpu" = {
            "interval" = 1;
            "format" = "󰍛 {usage}%";
          };
          # "mpd" = {
          #   "max-length" = 25;
          #   "format" = "<span foreground='#bb9af7'></span> {title}";
          #   "format-paused" = " {title}";
          #   "format-stopped" = "<span foreground='#bb9af7'></span>";
          #   "format-disconnected" = "";
          #   "on-click" = "mpc --quiet toggle";
          #   "on-click-right" = "mpc update; mpc ls | mpc add";
          #   "on-click-middle" = "kitty --class='ncmpcpp' ncmpcpp ";
          #   "on-scroll-up" = "mpc --quiet prev";
          #   "on-scroll-down" = "mpc --quiet next";
          #   "smooth-scrolling-threshold" = 5;
          #   "tooltip-format" = "{title} - {artist} ({elapsedTime:%M:%S}/{totalTime:%H:%M:%S})";
          # };
          "network" = {
            "interface" = "enp7s0";
            "format-disconnected" = "󰈂";
            "format-ethernet" = "󰈁";
            "interval" = 10;
            "tooltip" = false;
          };
          # "custom/powermenu" = {
          #   "format" = "";
          #   "on-click" = "pkill rofi || ~/.config/rofi/powermenu/type-3/powermenu.sh";
          #   "tooltip" = false;
          # };
          "tray" = {
            "icon-size" = 15;
            "spacing" = 5;
          };
          # "hyprland/workspaces" = {
          #   "all-outputs" = true;
          # };
          # "hyprland/window" = {
          #   "separate-outputs" = true;
          # };

            "ext/workspaces" = {
    "format" = "{icon}";
    "ignore-hidden"= true;
    "on-click"= "activate";
    "on-click-right"= "deactivate";
    "sort-by-id"= true;
  };
  "dwl/window"= {
    "format"= "[{layout}] {title}";
  };
        }
      ];
    };
  };
}
