{ pkgs, pkgs-unstable, ... }:
{

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager = {
    autoLogin = {
      enable = true;
      user = "simon";
    };
  };
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # https://nixos.wiki/wiki/GNOME
  systemd.services = {
    "getty@tty1".enable = false;
    "autovt@tty1".enable = false;
  };

  hardware.sensor.iio.enable = true;
}
