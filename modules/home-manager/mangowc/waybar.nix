{ config, lib, ... }:
{

  extra.waybar.settings.mangowc = [
    {
      layer = "top";
      position = "top";
      modules-left = [
        "mango/workspaces"
    "mango/layout"
    "mango/window"
      ];
      modules-center = [
        "clock"
      ];
      modules-right = [
            "mango/language"
    "mango/keymode"
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
      "mango/workspaces" = {
        format = "{index}";
        hide-empty = false;
        on-click = "activate";
        on-click-middle = "toogle";
      };
      "mango/window" = {
        format = " {}";
      };
        "mango/layout"= {
      "format"= "[{}]";
      # "format-S": "Scroller",
      # "format-T": "Tile",
  };
        "mango/keymode"= {
  	"format"= " [{mode}]";
  };
    }
  ];
}
