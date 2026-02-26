{ pkgs, pkgs-unstable, ... }:
{

  extra.gui = {
    enable = true;
    hyprland = true;
    i3 = true;
    is_docked = true;
  };

  hardware.opentabletdriver.enable = true;
}
