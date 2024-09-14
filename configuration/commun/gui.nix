{pkgs, pkgs-unstable, ...}:{

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  services.xserver.windowManager.i3 = {
    package = pkgs.i3-gaps;
    enable = true;
  };

  # enable hyprland
  programs.hyprland = {
    enable = true;
    package = pkgs-unstable.hyprland;
  };
}