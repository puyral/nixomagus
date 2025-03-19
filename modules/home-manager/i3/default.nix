{
  mconfig,
  pkgs,
  pkgs-stable,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.extra.i3;

  screen = "${pkgs.xorg.xrandr}/bin/xrandr " + cfg.xrandr;
  wallpaper = config.extra.wallpaper;
in
{
  imports = [
    ./rofi.nix
    ./picom.nix
    ./options.nix
  ];

  xsession.windowManager.i3 = mkIf cfg.enable {
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
        exec --no-startup-id ${./scripts/wallpaper.sh} ${wallpaper.path} ${builtins.toString wallpaper.duration}
      ''
      + (builtins.readFile ./config);
  };

  home.packages = mkIf cfg.enable (
    (with pkgs; [
      xorg.xrandr
      numlockx
      playerctl
      pamixer
      wmfocus
      xfce.thunar
      flameshot
      solaar
      brightnessctl
    ])
    ++ (with pkgs-stable; [ unclutter ])
  );
}
