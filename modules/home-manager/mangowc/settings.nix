{ lib, config, ... }:
with lib;
let
  cfg = config.extra.mangowc;

  # keys
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

  pseudoJson = strings.concatMapAttrsStringSep "," (n: v: "${n}:${v}");

  mkModKey = strings.concatStringsSep "+";
  mkArgs = strings.concatStringsSep ",";
  mkBind =
    mod: key: args:
    "bind=${
      mkArgs [
        (mkModKey mod)
        key
        (mkArgs args)
      ]
    }";
  mkMotion = f: (f "Up" "Down" "Left" "Right") ++ (f "k" "j" "l" "h");
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
  # mkMotion' = m: k: a: [mkBind [M] "Tab" ["focusstack" "next"]];
  mkBindTag =
    mod: key: args:
    map (t: mkBind mod (key t) (args t)) tags;

  viewtag = mkBindTag [ M ] id (t: [
    "view"
    t
    "0"
  ]);

  # tag: move client to the tag and focus it
  # tagsilent: move client to the tag and not focus it
  movetotag = mkBindTag [ M S ] id (t: [
    "tagsilent"
    t
    "0"
  ]);

  stacktags = mkBindTag [ M C ] id (t: [
    "toggleview"
    t
    "0"
  ]);

  # swap window
  swapwin = mkMotion' [ M S ] id (d: [
    "exchange_client"
    d
  ]);

  # switch window focus
  switchfocus = [
    (mkBind [ M ] "Tab" [
      "focusstack"
      "next"
    ])
  ]
  ++ (mkMotion' [ M ] id (d: [
    "focusdir"
    d
  ]));

  wallpaper = "exec=systemctl --user start ${config.vars.wallpaperTarget}";

  monitors = map (attrs: "monitorrule=${pseudoJson attrs}") cfg.monitors;

  settings =
    monitors
    ++ [
      (builtins.readFile ./config.conf)
      wallpaper
    ]
    ++ viewtag
    ++ movetotag
    ++ stacktags
    ++ swapwin
    ++ switchfocus;
in
{
  config = mkIf cfg.enable {
    wayland.windowManager.mango.settings = strings.concatStringsSep "\n" settings;
  };
}
