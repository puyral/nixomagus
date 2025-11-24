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
  cfg = config.extra.sway;
in
{
  imports = [
    ./options.nix
    ./config.nix
    ./bar.nix
  ];

  config = mkIf cfg.enable {
    wayland.windowManager.sway = {
      enable = true;
      package = pkgs.swayfx;
    };

    # Make sure the necessary packages are installed
    home.packages = with pkgs; [
      swayfx
      # waybar # or i3status
      # wofi
      alacritty
      flameshot
      wmfocus
      brightnessctl
      playerctl
      mpc
      pavucontrol
      dunst
      # unclutter
      # solaar
      # numlockx
      # swaynag
      # Add any other packages you need
    ];
  };

  # xsession.windowManager.i3 = mkIf cfg.enable {
  #   enable = true;

  #   # config = { startup = [
  #   #   {command = "${pkgs.solaar} --window=hide"; notification = false;}
  #   # ];};
  #   config = null;

  #   extraConfig =
  #     ''
  #       set $scripts ${./scripts}
  #       exec ${screen}
  #       exec --no-startup-id ${./scripts/wallpaper.sh} ${wallpaper.path} ${builtins.toString wallpaper.duration}
  #     ''
  #     + (builtins.readFile ./config);
  # };

}
