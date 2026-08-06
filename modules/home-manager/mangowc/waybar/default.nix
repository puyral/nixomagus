{
  config,
  lib,
  pkgs,
  pkgs-self,
  ...
}:
let
  cfg = config.extra.mangowc;
  main_monitor = builtins.head cfg.monitors;
  head = main_monitor.name;
  others = builtins.filter (m: m.name != head) cfg.monitors;

  base = {
    layer = "top";
    position = "top";
    modules-left = [
      "mango/workspaces"
      "mango/layout"
      "mango/window"
    ];
    "mango/layout" = {
      format = "[{}]";
    };
    "mango/window" = {
      format = " {}";
    };
    "mango/workspaces" = {
      format = "{index}";
      "hide-empty" = false;
      "on-click" = "activate";
      "on-click-middle" = "toogle";
    };
  };

  # Full-featured bar shown on the head monitor
  headBar = base // {
    output = head;
    modules-center = [ "clock" ];
    modules-right = [
      "mango/language"
      "mango/keymode"
      "pulseaudio"
      "memory"
      "cpu"
      "network"
      "tray"
    ];
    cpu = {
      format = "󰍛 {usage}%";
      interval = 1;
    };
    "mango/keymode" = {
      format = " [{mode}]";
    };
    "mango/layout" = {
      format = "[{}]";
    };
    "mango/window" = {
      format = " {}";
    };
    "mango/workspaces" = {
      format = "{index}";
      "hide-empty" = false;
      "on-click" = "activate";
      "on-click-middle" = "toogle";
    };
    memory = {
      format = "󰻠 {percentage}%";
      interval = 1;
      states = {
        warning = 85;
      };
    };
    network = {
      "format-disconnected" = "󰈂";
      "format-ethernet" = "󰈁";
      interface = "enp7s0";
      interval = 10;
      tooltip = false;
    };
    pulseaudio = {
      format = "{icon} {volume}%";
      "format-icons" = {
        default = [
          ""
          ""
          ""
        ];
      };
      "format-muted" = "󰖁 Muted";
      "on-click" = "pamixer -t";
      "scroll-step" = 1;
      tooltip = false;
    };
    tray = {
      "icon-size" = 15;
      spacing = 5;
    };
    clock = {
      format = "{:%T  %A %b %d}";
      interval = 1;
    };
  };

  # Minimal bar on every non-head monitor: just the clock, on the right
  otherBar = base // {
    layer = "top";
    position = "top";
    output = map (m: m.name) others;
    modules-right = [ "clock" ];
    clock = {
      format = "{:%T}";
      interval = 1;
    };
  };

  waybarConfig = [ headBar ] ++ lib.optional (others != [ ]) otherBar;
  waybarJson = builtins.toJSON waybarConfig;
in

{
  config = lib.mkIf cfg.enable {
    xdg = {
      enable = true;
      configFile = {
        "mango/waybar/style.css".source = ./style.css;
        "mango/waybar/config.jsonc".text = "${waybarJson}\n";
      };
    };
  };
}
