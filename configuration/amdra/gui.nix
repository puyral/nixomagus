{ pkgs, pkgs-unstable, ... }:
{
  extra.gui = {
    enable = true;
    hyprland = true;
    i3 = true;
  };

  hardware.opentabletdriver.enable = true;
}
