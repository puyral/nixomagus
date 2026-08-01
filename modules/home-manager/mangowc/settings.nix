{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.extra.mangowc;

  M = "SUPER";
  S = "SHIFT";
  A = "ALT";
  C = "CTRL";

  tags = map toString [
    1
    2
    3
    4
    5
    6
    7
    8
    9
  ];
  id = x: x;

  mkModKey = arg: if isList arg then strings.concatStringsSep "+" arg else arg;
  mkArgs = strings.concatStringsSep ",";
  mkPseudoJson = strings.concatMapAttrsStringSep "," (n: v: "${n}:${v}");
  mkBind =
    mod: key: args:
    mkArgs [
      (mkModKey mod)
      key
      (mkArgs args)
    ];
  mkMotion = f: (f "Up" "Down" "Left" "Right") ++ (f "k" "j" "h" "l");
  mkMotion' =
    m: k: a:
    mkMotion (
      u: d: l: r: [
        (mkBind m (k u) (a "up"))
        (mkBind m (k d) (a "down"))
        (mkBind m (k l) (a "left"))
        (mkBind m (k r) (a "right"))
      ]
    );
  mkBindTag =
    mod: key: args:
    map (t: mkBind mod (key t) (args t)) tags;

  viewtag = mkBindTag [ M ] id (t: [
    "view"
    t
    "0"
  ]);
  stacktags = mkBindTag [ M C ] id (t: [
    "toggleview"
    t
    "0"
  ]);
  movetotag = mkBindTag [ M S ] id (t: [
    "tagsilent"
    t
    "0"
  ]);
  stacktagswindow = mkBindTag [ M S C ] id (t: [
    "toggletag"
    t
    "0"
  ]);
  swapwin = mkMotion' [ M S ] id (d: [
    "exchange_client"
    d
  ]);
  switchfocus = [
    (mkBind M "Tab" [
      "focusstack"
      "next"
    ])
  ]
  ++ (mkMotion' M id (d: [
    "focusdir"
    d
  ]));

    monitors = map (attrs: "monitorrule=${mkPseudoJson attrs}") cfg.monitors;

  anyrun = [
    (mkBind M "Space" [
      "spawn"
      "anyrun"
    ])
  ];

  alacritty = [
    (mkBind M "T" [
      "spawn"
      "alacritty"
    ])
    (mkBind [ M S ] "T" [
      "spawn"
      "alacritty"
    ])
  ];

  mediaKeys = [
    (mkBind "NONE" "XF86AudioPlay" [
      "spawn"
      "playerctl play-pause"
    ])
    (mkBind "NONE" "XF86AudioNext" [
      "spawn"
      "playerctl next"
    ])
    (mkBind "NONE" "XF86AudioPrev" [
      "spawn"
      "playerctl previous"
    ])
    (mkBind "NONE" "XF86AudioRaiseVolume" [
      "spawn"
      "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
    ])
    (mkBind "NONE" "XF86AudioLowerVolume" [
      "spawn"
      "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-"
    ])
    (mkBind "NONE" "XF86AudioMute" [
      "spawn"
      "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
    ])
  ];

  window_effects = {

    blur = 1;
    blur_layer = 0;
    blur_optimized = 1;
    blur_params = {
      num_passes = 2;
      radius = 20;
      noise = 0.02;
      brightness = 0.9;
      contrast = 0.9;
      saturation = 1.2;
    };

    shadows = 0;
    layer_shadows = 0;
    shadow_only_floating = 1;
    shadows_size = 10;
    shadows_blur = 15;
    shadows_position_x = 0;
    shadows_position_y = 0;
    shadowscolor = "0x000000ff";

    border_radius = 6;
    no_radius_when_single = 0;
    focused_opacity = 1.0;
    unfocused_opacity = 0.95;
  };

  annimations = {
    animations = 1;
    layer_animations = 1;
    animation_type_open = "slide";
    animation_type_close = "slide";
    layer_animation_type_open="zoom";
    layer_animation_type_close="zoom";
    animation_fade_in = 1;
    animation_fade_out = 1;
    tag_animation_direction = 1;
    zoom_initial_ratio = 0.3;
    zoom_end_ratio = 0.8;
    fadein_begin_opacity = 0.5;
    fadeout_begin_opacity = 0.8;
    animation_duration_move = 500;
    animation_duration_open = 400;
    animation_duration_tag = 350;
    animation_duration_close = 800;
    animation_duration_focus = 0;
    animation_curve = {
      open = "0.46,1.0,0.29,1";
      move = "0.46,1.0,0.29,1";
      tag = "0.46,1.0,0.29,1";
      close = "0.08,0.92,0,1";
      focus = "0.46,1.0,0.29,1";
      opafadeout = "0.5,0.5,0.5,0.5";
      opafadein = "0.46,1.0,0.29,1";
    };
  };

  layouts = {

    # Scroller Layout
    scroller_structs = 20;
    scroller_default_proportion = 0.5;
    scroller_focus_center = 0;
    scroller_prefer_center = 0;
    edge_scroller_pointer_focus = 0;
    scroller_default_proportion_single = 1;
    scroller_proportion_preset = "0.5,0.8,1.0";

    # Master-Stack Layout
    new_is_master = 0;
    default_mfact = 0.65;
    default_nmaster = 1;
    smartgaps = 1;

    # Overview
    hotarea_size = 10;
    enable_hotarea = 0;
    ov_tab_mode = 0;
    overviewgappi = 5;
    overviewgappo = 30;
  };

  misc = {

    no_border_when_single = 0;
    axis_bind_apply_timeout = 100;
    focus_on_activate = 0;
    idleinhibit_ignore_visible = 0;
    sloppyfocus = 1;
    warpcursor = 1;
    focus_cross_monitor = 0;
    focus_cross_tag = 0;
    enable_floating_snap = 0;
    snap_distance = 30;
    cursor_size = 32;
    cursor_theme = "Adwaita";
    drag_tile_to_tile = 1;
  };

  inputs = {

    # Keyboard
    repeat_rate = 50;
    repeat_delay = 600;
    numlockon = 1;
    xkb_rules_layout = "custom";
    xkb_rules_options = "compose:menu";

    # Trackpad
    disable_trackpad = 0;
    tap_to_click = 1;
    tap_and_drag = 1;
    drag_lock = 1;
    trackpad_natural_scrolling = 0;
    disable_while_typing = 1;
    left_handed = 0;
    middle_button_emulation = 0;
    swipe_min_threshold = 1;

    # Mouse
    mouse_natural_scrolling = 0;
    mouse_accel_speed = "-0.1";
    mouse_accel_profile = 2;
  };

  appearence = {
    gappih = 5;
    gappiv = 5;
    gappoh = 10;
    gappov = 10;
    scratchpad_width_ratio = 0.8;
    scratchpad_height_ratio = 0.9;
    borderpx = 4;
    rootcolor = "0x201b14ff";
    bordercolor = "0x444444ff";
    focuscolor = "0xc9b890ff";
    maximizescreencolor = "0x89aa61ff";
    urgentcolor = "0xad401fff";
    scratchpadcolor = "0x516c93ff";
    globalcolor = "0xb153a7ff";
    overlaycolor = "0x14a57cff";
  };

  mousebind = [
    (mkArgs [
      (mkModKey [ M ])
      "btn_left"
      (mkArgs [
        "moveresize"
        "curmove"
      ])
    ])
    (mkArgs [
      (mkModKey [ M ])
      "btn_middle"
      (mkArgs [
        "togglemaximizescreen"
        "0"
      ])
    ])
    (mkArgs [
      (mkModKey [ M ])
      "btn_right"
      (mkArgs [
        "moveresize"
        "curresize"
      ])
    ])
  ];

  # Axis bindings
  axisbind = [
    (mkArgs [
      (mkModKey [ M ])
      "UP"
      "viewtoleft_have_client"
    ])
    (mkArgs [
      (mkModKey [ M ])
      "DOWN"
      "viewtoright_have_client"
    ])
  ];

  tagRelative =
    # tag switch
    (
      mkMotion (
        _: _: l: r: [
          (mkBind [ C M ] l [
            "viewtoleft_have_client"
            "0"
          ])
          (mkBind [ C M ] r [
            "viewtoright_have_client"
            "0"
          ])
        ]
      )
    );

  monitorMotions =
    # monitor switch
    mkMotion' [ M A ] id (d: [
      "focusmon"
      d
    ])
    ++ mkMotion' [ M A S ] id (d: [
      "tagmon"
      d
    ])

  ;

  toogles = [
    (mkBind [ M ] "g" [
      "toggleglobal"
      ""
    ])
    (mkBind [ A M ] "Tab" [
      "toggleoverview"
      ""
    ])
    (mkBind [ M ] "V" [
      "togglefloating"
      ""
    ])
    (mkBind [ M ] "a" [
      "togglemaximizescreen"
      ""
    ])
    (mkBind [ M ] "F" [
      "togglefullscreen"
      "0"
    ])
    (mkBind [ M S ] "f" [
      "togglefakefullscreen"
      ""
    ])
    (mkBind [ M ] "i" [
      "minimized"
      ""
    ])
    (mkBind [ M ] "o" [
      "toggleoverlay"
      ""
    ])
    (mkBind [ M S ] "I" [ "restore_minimized" ])
    (mkBind [ M ] "z" [ "toggle_scratchpad" ])
  ];

  scrolling = [
    (mkBind [ M ] "e" [
      "set_proportion"
      "1.0"
    ])
    (mkBind [ M ] "x" [
      "switch_proportion_preset"
      ""
    ])
    (mkBind [ M ] "n" [ "switch_layout" ])
  ];

  base = [
    (mkBind [ M ] "r" [ "reload_config" ])
    (mkBind [ M ] "E" [ "quit" ])
    (mkBind [ M ] "Q" [
      "killclient"
      ""
    ])

    (mkBind "NONE" "Print" (with pkgs; [
      "spawn_shell"
      "${grim}/bin/grim -l 0 -g \"$(${slurp}/bin/slurp)\" - | ${wl-clipboard}/bin/wl-copy"
    ]))
  ];

in
{
  config = mkIf cfg.enable {
    wayland.windowManager.mango = {
      settings =
        window_effects
        // annimations
        // layouts
        // misc
        // inputs
        // appearence
        // {
          inherit mousebind axisbind;
          # Layout rules
          tagrule = map (
            id:
            mkPseudoJson {
              id = id;
              layout_name = "tile";
            }
          ) tags;

          # Key bindings
          bind =
            alacritty
            ++ mediaKeys
            ++ viewtag
            ++ movetotag
            ++ stacktagswindow
            ++ stacktags
            ++ swapwin
            ++ switchfocus
            ++ tagRelative
            ++ toogles
            ++ scrolling
            ++ monitorMotions
            ++ base;

          # Mouse bindings

          # Layer rules
          layerrule = [
            "animation_type_open:zoom,layer_name:rofi"
            "animation_type_close:zoom,layer_name:rofi"
          ];

          keymode = {
            common = {
              bind = anyrun;
            };
          };
        };

      extraConfig = strings.concatStringsSep "\n" monitors;
    };
  };
}
