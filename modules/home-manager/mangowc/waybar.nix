{ config, lib, ... }:
{
  extra.waybar.settings.mangowc = [
    {
      layer = "top";
      position = "top";
      modules-left = [
        "ext/workspaces"
        "dwl/window"
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
      pulseaudio = {
        scroll-step = 1;
        format = "{icon} {volume}%";
        format-muted = "󰖁 Muted";
        format-icons = {
          default = [
            ""
            ""
            ""
          ];
        };
        on-click = "pamixer -t";
        tooltip = false;
      };
      clock = {
        interval = 1;
        format = "{:%T  %A %b %d}";
      };
      memory = {
        interval = 1;
        format = "󰻠 {percentage}%";
        states = {
          warning = 85;
        };
      };
      cpu = {
        interval = 1;
        format = "󰍛 {usage}%";
      };
      network = {
        interface = "enp7s0";
        format-disconnected = "󰈂";
        format-ethernet = "󰈁";
        interval = 10;
        tooltip = false;
      };
      tray = {
        icon-size = 15;
        spacing = 5;
      };
      "ext/workspaces" = {
        format = "{icon}";
        ignore-hidden = true;
        on-click = "activate";
        on-click-right = "deactivate";
        sort-by-id = true;
      };
      "dwl/window" = {
        format = "[{layout}] {title}";
      };
    }
  ];
}
