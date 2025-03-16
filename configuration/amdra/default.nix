{
  # kmonad,
  pkgs,
  config,
  ...
}:
{

  imports = [
    ./filesystem.nix
    ./services
    # ./kmonad
    ./hardware-configuration.nix
    ../commun/sound.nix
    ../commun/bluetooth.nix
    # kmonad.nixosModules.default
    ./gui.nix
  ];

  extra = {
    splash_screen.enable = false;
    v4l2loopback.enable = true;
    keyboard.enable = true;
  };

  fonts.packages = with pkgs; [
    nerdfonts
    fira-code
  ];

  # wayland
  environment.sessionVariables = {
  };

  services.openssh = {
    settings = {
      X11Forwarding = true;
    };
  };

  # v4l2loopback

  programs.gnupg.agent.pinentryPackage = pkgs.pinentry-gnome3;

  # docker
  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
    # rootless = {
    #   enable = true;
    #   setSocketVariable = true;
    # };
  };

}
