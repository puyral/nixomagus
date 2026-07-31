{ pkgs, pkgs-unstable, ... }:
{
  imports = [
    ../../overlays/jellyfin.nix
  ];
  extra.gui = {
    enable = true;
    hyprland = false;
    i3 = false;
    sway = true;
    mangowc = true;
  };

  hardware.opentabletdriver.enable = true;

  #  services.displayManager.autoLogin.user = "simon";
  #services.displayManager.autoLogin.enable = true;
  #systemd.services."getty@tty1".enable = false;
  #  systemd.services."autovt@tty1".enable = false;
}
