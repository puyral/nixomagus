{
  mconfig,
  pkgs,
  pkgs-unstable,
  ...
}:
let

  screen =
    "${pkgs.xorg.xrandr}/bin/xrandr "
    + (
      if mconfig.is_docked then
        "--output HDMI-0 --primary --mode 3840x2160 --pos 1280x0 --rotate normal --output DP-0 --mode 1280x1024 --pos 0x0 --rotate normal --output DP-1 --off --output eDP-1-1 --mode 1920x1080 --pos 5120x903 --rotate normal --output DP-1-1 --off --output HDMI-1-1 --off"
      else
        "--output eDP-1-1 --mode 1920x1080 --rotate normal --output DP-1-1 --off --output HDMI-1-1 --off"
    );
in
rec {
  imports = [
    ./rofi.nix
    ./picom.nix
  ];

  xsession.windowManager.i3 = {
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
        exec --no-startup-id ${./scripts/wallpaper.sh} 1200
      ''
      + (builtins.readFile ./config);
  };

  programs.rofi = {
    enable = true;
  };

  home.packages = (
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
