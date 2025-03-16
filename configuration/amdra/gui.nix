{ pkgs, pkgs-unstable, ... }:
{

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

  # https://nixos.wiki/wiki/Visual_Studio_Code#Error_after_Sign_On
  services.gnome.gnome-keyring.enable = true;

  extra.printing.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    # dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };
}
