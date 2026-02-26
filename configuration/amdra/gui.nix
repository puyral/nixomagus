{ pkgs, pkgs-unstable, ... }:
{
  extra.gui = {
    enable = true;
    hyprland = true;
    i3 = true;
    sway = true;
    mangowc = true;
  };

  hardware.opentabletdriver.enable = true;

  #  services.displayManager.autoLogin.user = "simon";
  #services.displayManager.autoLogin.enable = true;
  #systemd.services."getty@tty1".enable = false;
  #  systemd.services."autovt@tty1".enable = false;
}
