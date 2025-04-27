{
  kmonad,
  pkgs,
  config,
  ...
}:
{

  imports = [
    ./filesystem.nix
    ./services
    ./nvidia.nix
    ./hardware-configuration.nix
    ../commun/sound.nix
    ../commun/bluetooth.nix
    ./gui.nix
  ];

  extra = {
    splash_screen.enable = false;
    v4l2loopback.enable = true;
    # keyboard.enable = true;
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
    # "__NV_PRIME_RENDER_OFFLOAD" = "1";
    # "__NV_PRIME_RENDER_OFFLOAD_PROVIDER" = "NVIDIA-G0";
    # "__GLX_VENDOR_LIBRARY_NAME" = "nvidia";
    # "__VK_LAYER_NV_optimus" = "NVIDIA_only";
  };

  services.openssh = {
    settings = {
      X11Forwarding = true;
    };
  };

  # services.isw.enable = true;

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
