attrs@{
  i3,
  lib,
  mconfig,
  config,
  pkgs,
  mlib,
  ...
}:
let
  monitor-cfg = config.extra.hyprland.monitors;
  # defaultMonitor =
  #   if config.extra.hyprland.defaultMonitor == null then
  #     (with builtins; (elemAt (elemAt monitor-cfg 0) 0))
  #   else
  #     config.extra.hyprland.defaultMonitor;
  alacritty_float_class = "alacritty_float";
  toogle_fs_script = pkgs.callPackage ./scripts/toogle_fs.nix { };
  cfg = config.extra.hyprland;
in
{
  exec-once = [
    "args -b hypr"
    "waybar"
    "[workspace 1 silent] firefox"
    "[workspace 17 silent] thunderbird"
    "hyprctl dispatch workspace 1"
    "systemctl --user start ${config.vars.wallpaperTarget}"
  ];

  monitor = map (builtins.concatStringsSep ",") monitor-cfg;

  general = {
    resize_on_border = true;
    layout = "hy3";
  };

  input = {
    follow_mouse = 1;
    kb_options = "compose:menu";
    kb_layout = "custom";
    # kb_file = ./layout.xkb;

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

  workspace = # for i in 1..=10 -> map n*10 + i to the nth monitor
    let
      activeMonitors = with builtins; filter (m: !(elem "disable" m)) cfg.monitors;
      monitors = with builtins; map head activeMonitors;
      idx = lib.range 1 10;

      mkListOne =
        id: m:
        map (i: {
          name = 10 * id + i;
          value = m;
        }) idx;
      mkLists = lib.imap0 mkListOne monitors;
      baseList = builtins.concatLists mkLists;

      generateOne = { name, value }: "${name}:${builtins.toString value}";
      generate =
        attrs:
        let
          as_list = lib.attrsToList attrs;
          preprocessed = map generateOne as_list;
        in
        (builtins.concatStringsSep ",") preprocessed;

      extras = [ ];
    in
    map generate (baseList ++ extras);

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

  "plugin:dynamic-cursors" = {
    # see https://github.com/VirtCode/hypr-dynamic-cursors
    mode = "stretch";
    shake = {
      enable = false;
    };
    stretch = {
      # controls how much the cursor is stretched
      # this value controls at which speed (px/s) the full stretch is reached
      limit = 3000;

      # relationship between speed and stretch amount, supports these values:
      # linear             - a linear function is used
      # quadratic          - a quadratic function is used
      # negative_quadratic - negative version of the quadratic one, feels more aggressive
      function = "quadratic";

    };
  }; # // { hy3 = lib.mkIf i3 ((import ./hy3.nix) attrs); };
}
// (import ./key_bindings.nix) attrs
