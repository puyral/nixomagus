{ pkgs, rootDir, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./gui.nix
    ./syncthing.nix
    (rootDir + /overlays/jellyfin.nix)
  ];
  services.openssh = {
    settings = {
      X11Forwarding = true;
    };
  };
  programs.gnupg.agent.pinentryPackage = pkgs.pinentry-gnome3;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  nix.distributedBuilds = true;
}
