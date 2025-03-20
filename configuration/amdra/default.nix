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
    ./hardware-configuration.nix
    ../commun/sound.nix
    ../commun/bluetooth.nix
    ./gui.nix
    ./amdgpu.nix
    ./zfs.nix
    ./networking.nix
  ];

  extra = {
    splash_screen.enable = false;
    v4l2loopback.enable = true;
    keyboard.enable = true;
  };

  fonts.packages =
    with pkgs;
    [
      # nerdfonts
      fira-code
    ]
    ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

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
