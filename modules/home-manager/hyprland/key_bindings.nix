{ i3, lib, ... }:
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

  # to use the hy3 commands
  mki3 = str: if i3 then "hy3:${str}" else str;
  alacritty_float_class = "alacritty_float";

in
{

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
        (mki3 "movewindow")
      ]
      [
        mod
        rightclick
        (mki3 "resizewindow")
      ]
      [
        "Alt_R"
        leftclick
        (mki3 "movewindow")
      ]
      [
        "Alt_R"
        rightclick
        (mki3 "resizewindow")
      ]
    ];

  # bind even locked and repeat
  bindle =
    let
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
    in
    map mbind (media);

  # bind even locked
  bindl =
    let
      media = [
        [
          ""
          "XF86AudioPlay"
          exec
          "playerctl play-pause"
        ]
        [
          ""
          "XF86AudioNext"
          exec
          "playerctl next"
        ]
        [
          ""
          "XF86AudioPrev"
          exec
          "playerctl previous"
        ]
      ];
    in
    map mbind (media);

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
        # [
        #   (mod + alt)
        #   "V"
        #   "hy3:tooglefocuslayer"
        # ]

        [
          mod
          tab
          "cyclenext"
        ]

      ];
      groups =
        if i3 then
          [
            [
              (alt + mod)
              "H"
              "hy3:makegroup"
              "h"
            ]
            [
              (alt + mod)
              "V"
              "hy3:makegroup"
              "v"
            ]
            [
              (alt + mod)
              "T"
              "hy3:makegroup"
              "tab"
            ]

            [
              (shift + alt + mod)
              "H"
              "hy3:changegroup"
              "h"
            ]
            [
              (shift + alt + mod)
              "V"
              "hy3:changegroup"
              "v"
            ]
            [
              (shift + alt + mod)
              "T"
              "hy3:changegroup"
              "tab"
            ]
          ]
        else
          [
            [
              mod
              "G"
              "togglegroup"
            ]
            [
              (mod + alt)
              "G"
              "changegroupactive"
              "b"
            ]
            [
              (mod + alt + shift)
              "G"
              "changegroupactive"
              "f"
            ]
            [
              (mod + ctrl + alt)
              "left"
              "moveintogroup"
              "left"
            ]
            [
              (mod + ctrl + alt)
              "right"
              "moveintogroup"
              "right"
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
      launcher =
        let
          keymap = key: [
            [
              mod
              key
              exec
              "wofi --show drun --height=984 --style=$HOME/.config/wofi.css --term=footclient --prompt=Run"
            ]
            [
              (mod + shift)
              key
              exec
              "wofi --show run --height=984 --style=$HOME/.config/wofi.css --term=footclient --prompt=Run"
            ]
          ];
        in
        keymap "Space" ++ keymap "D";
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
                  (mki3 "movewindow")
                  "l"
                ]
                [
                  (mod + shift)
                  r
                  (mki3 "movewindow")
                  "r"
                ]
                [
                  (mod + shift)
                  u
                  (mki3 "movewindow")
                  "u"
                ]
                [
                  (mod + shift)
                  d
                  (mki3 "movewindow")
                  "d"
                ]
              ];
              focus = [
                [
                  mod
                  l
                  (mki3 "movefocus")
                  "l"
                ]
                [
                  mod
                  r
                  (mki3 "movefocus")
                  "r"
                ]
                [
                  mod
                  u
                  (mki3 "movefocus")
                  "u"
                ]
                [
                  mod
                  d
                  (mki3 "movefocus")
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
                (mki3 "movetoworkspace")
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
                (mki3 "movetoworkspace")
                ws_name
              ]
            ]
          ) 10
        )
      );

    in
    map mbind (basics ++ terminals ++ launcher ++ powerManagement ++ movements ++ workspaces ++ groups);

}
