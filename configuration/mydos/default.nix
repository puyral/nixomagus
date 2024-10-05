{
  pkgs,
  rootDir,
  nixos-hardware,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    (rootDir + /overlays/jellyfin.nix)
    ./gui.nix
    ./waydroid.nix
    # ./howdy.nix # the camera isn't supported yet
  ];
  extra.splash_screen.enable = true;

  extra.refind.enable = true;

  services.openssh = {
    settings = {
      X11Forwarding = true;
    };
  };
  programs.gnupg.agent.pinentryPackage = pkgs.pinentry-gnome3;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  nix.distributedBuilds = true;
}
