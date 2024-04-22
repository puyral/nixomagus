{ pkgs, pkgs-unstable, ... }: rec {
  imports = [ ./rofi.nix ./picom.nix ];
  xsession.windowManager.i3 = {
    package = pkgs.i3-gaps;
    enable = true;

    # config = { startup = [
    #   {command = "${pkgs.solaar} --window=hide"; notification = false;}
    # ];};
    config = null;

    extraConfig = ''
      set $scripts ${./scripts}
      exec --no-startup-id ${./scripts/screen.sh} 1200
    '' + (builtins.readFile ./config);
  };

  programs.rofi = { enable = true; };

  home.packages = (with pkgs; [
    numlockx
    playerctl
    pamixer
    wmfocus
    xfce.thunar
    flameshot
    solaar
    unclutter
    brightnessctl
  ]);
}
