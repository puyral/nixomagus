{
  mconfig,
  pkgs,
  pkgs-unstable, config, lib,
  ...
}:
with lib;
let
  cfg =config.extra.i3;

  screen =
    "${pkgs.xorg.xrandr}/bin/xrandr "
    # + (
    #   if mconfig.is_docked then
    #     "--output HDMI-0 --primary --mode 3840x2160 --pos 1280x0 --rotate normal --output DP-0 --mode 1280x1024 --pos 0x0 --rotate normal --output DP-1 --off --output eDP-1-1 --mode 1920x1080 --pos 5120x903 --rotate normal --output DP-1-1 --off --output HDMI-1-1 --off"
    #   else
    #     "--output eDP-1-1 --mode 1920x1080 --rotate normal --output DP-1-1 --off --output HDMI-1-1 --off"
    # );
    + cfg.xrandr;
  wallpaper = config.extra.wallpaper;
in
{
  imports = [
    ./rofi.nix
    ./picom.nix
    ./options.nix
  ];

  xsession.windowManager.i3 = mkIf cfg.enable{
    package = pkgs.i3-gaps;
    enable = true;

    # config = { startup = [
    #   {command = "${pkgs.solaar} --window=hide"; notification = false;}
    # ];};
    config = null;

    extraConfig =
      ''
        set $scripts ${./scripts}
        exec ${screen}
        exec --no-startup-id ${./scripts/wallpaper.sh} ${wallpaper.path} ${wallpaper.duration}
      ''
      + (builtins.readFile ./config);
  };

  home.packages = mkIf cfg.enable (
    with pkgs;
    [
      xorg.xrandr
      numlockx
      playerctl
      pamixer
      wmfocus
      xfce.thunar
      flameshot
      solaar
      unclutter
      brightnessctl
    ]
  );
}
