{
  lib,
  mconfig,
  config,
  pkgs,
  ...
}:
let
  modulo = a: b: a - (b * (a / b));
  mod = "SUPER";
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
  monitor-cfg = config.extra.hyprland.monitors;
  defaultMonitor =
    if config.extra.hyprland.defaultMonitor == null then
      (with builtins; (elemAt (elemAt monitor-cfg 0) 0))
    else
      config.extra.hyprland.defaultMonitor;
  alacritty_float_class = "alacritty_float";
  toogle_fs_script = pkgs.callPackage ./scripts/toogle_fs.nix { };
in
{
  exec-once = [
    "args -b hypr"
    "wpaperd"
    "waybar"
    "[workspace 1 silent] firefox"
    "[workspace 17 silent] thunderbird"
    "hyprctl dispatch workspace 1"
  ];

  monitor = map (builtins.concatStringsSep ",") monitor-cfg;

  general = {
    resize_on_border = true;
  };

  input = {
    follow_mouse = 1;
    # kb_options = "caps:swapescape";
    repeat_rate = 50;
    numlock_by_default = true;
  };

  decoration = {
    shadow = {
      enabled = true;
      range = 10;
      render_power = 2;
    };
    # col = {
    # shadow = "0x55000000";
    # shadow_inactive = "0x55000000";
    # };
    rounding = 4;
  };

  dwindle = {
    smart_split = true;
  };

  # see wev
  bindm =
    let
      leftclick = "mouse:272";
      rightclick = "mouse:273";
    in
    map mbind [
      [
        mod
        leftclick
        "movewindow"
      ]
      [
        mod
        rightclick
        "resizewindow"
      ]
      [
        "Alt_R"
        leftclick
        "movewindow"
      ]
      [
        "Alt_R"
        rightclick
        "resizewindow"
      ]
    ];

  bind =
    let
      basics = [
        [
          mod
          "E"
          "exit"
        ]
        [
          mod
          "Q"
          "killactive"
        ]
        [
          mod
          "F"
          "fullscreen"
          "0"
        ]
        [
          (mod + shift)
          "F"
          # "exec"
          # "${toogle_fs_script}/bin/toogle_fs"
          "fullscreenstate"
          "0"
          "2"
        ]
        [
          (mod + shift + ctrl)
          "F"
          # "exec"
          # "${toogle_fs_script}/bin/toogle_fs"
          "fullscreenstate"
          "0"
          "-1"
        ]
        [
          mod
          "V"
          "togglefloating"
          "active"
        ]

        [
          mod
          tab
          "cyclenext"
        ]

      ];
      terminals = [
        [
          alt
          "T"
          exec
          "alacritty"
        ]
        [
          mod
          "T"
          exec
          "alacritty --class ${alacritty_float_class}"
        ]
        [
          ""
          "XF86HomePage"
          exec
          "alacritty --class ${alacritty_float_class}"
        ]
        [
          (shift + mod)
          "T"
          exec
          "alacritty"
        ]
        [
          mod
          "O"
          exec
          "kitty"
        ]
      ];
      launcher = [
        [
          mod
          "U"
          exec
          "wofi --show drun --height=984 --style=$HOME/.config/wofi.css --term=footclient --prompt=Run"
        ]
        [
          mod
          "D"
          exec
          "wofi --show drun"
        ]
        [
          (mod + shift)
          "D"
          exec
          "wofi --show run"
        ]
        [
          mod
          "Space"
          exec
          "wofi --show drun"
        ]
      ];
      media = [
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
      ];
      powerManagement = [
        [
          (mod + shift)
          "s"
          exec
          "sleep 1 && hyprctl dispatch dpms on"
        ]
        [
          (mod + ctrl)
          "s"
          exec
          "sleep 1 && hyprctl dispatch dpms off"
        ]
      ];

      movements = (
        let
          mmove =
            {
              l,
              r,
              u,
              d,
            }:
            let
              window = [
                [
                  (mod + shift)
                  l
                  "movewindow"
                  "l"
                ]
                [
                  (mod + shift)
                  r
                  "movewindow"
                  "r"
                ]
                [
                  (mod + shift)
                  u
                  "movewindow"
                  "u"
                ]
                [
                  (mod + shift)
                  d
                  "movewindow"
                  "d"
                ]
              ];
              focus = [
                [
                  mod
                  l
                  "movefocus"
                  "l"
                ]
                [
                  mod
                  r
                  "movefocus"
                  "r"
                ]
                [
                  mod
                  u
                  "movefocus"
                  "u"
                ]
                [
                  mod
                  d
                  "movefocus"
                  "d"
                ]
              ];
              ws-monitor = [

                [
                  (mod + ctrl)
                  l
                  "movecurrentworkspacetomonitor"
                  "l"
                ]
                [
                  (mod + ctrl)
                  r
                  "movecurrentworkspacetomonitor"
                  "r"
                ]
              ];
            in
            window ++ focus ++ ws-monitor;
        in
        mmove arrow_keys ++ mmove vim_keys
      );

      workspaces = (
        # workspaces
        # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
        builtins.concatLists (
          builtins.genList (
            x:
            let
              ws = x + 1;
              ws_key = toString (modulo ws 10);
              ws_name = toString ws;
            in
            [
              [
                mod
                ws_key
                "workspace"
                ws_name
              ]
              [
                (mod + shift)
                ws_key
                "movetoworkspace"
                ws_name
              ]
            ]
          ) 10
          ++ builtins.genList (
            x:
            let
              ws = x + 1;
              ws_key = toString (modulo ws 10);
              ws_name = toString (ws + 10);
            in
            [
              [
                (mod + ctrl)
                ws_key
                "workspace"
                ws_name
              ]
              [
                (mod + ctrl + shift)
                ws_key
                "movetoworkspace"
                ws_name
              ]
            ]
          ) 10
        )
      );

    in
    map mbind (basics ++ terminals ++ launcher ++ media ++ powerManagement ++ movements ++ workspaces);

  workspace =
    let
      inner =
        { name, value }:
        # if name == "name" && builtins.isInt value then builtins.toString value else
        "${name}:${builtins.toString value}";
      generate =
        attrs:
        let
          as_list = lib.attrsToList attrs;
          preprocessed = map inner as_list;
        in
        (builtins.concatStringsSep ",") preprocessed;
    in
    map generate [
      {
        name = 1;
        monitor = defaultMonitor;
      }
    ];

  windowrule =
    with builtins;
    (
      let
        each =
          attrs@{ rule, ... }:
          let
            others = removeAttrs attrs [ "rule" ];
            lefover = lib.mapAttrsToList (n: v: "${n}:${v}") others;
          in
          lib.concatStringsSep "," ([ rule ] ++ lefover);
        gather = map each;
      in
      gather [
        {
          rule = "float";
          class = alacritty_float_class;
        }
      ]
    );

  misc = {
    disable_hyprland_logo = true;
    force_default_wallpaper = 0;
    disable_autoreload = false;
  };

  xwayland = {
    force_zero_scaling = true;
  };
}
