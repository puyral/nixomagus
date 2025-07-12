{ pkgs, pkgs-unstable, ... }:
{
  extra.gui = {
    enable = true;
    hyprland = true;
    i3 = true;
    sway = true;
  };

  hardware.opentabletdriver.enable = true;
}
