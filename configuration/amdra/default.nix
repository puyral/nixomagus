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
    ./rgb.nix
  ];

  extra = {
    splash_screen.enable = false;
    v4l2loopback.enable = true;
    keyboard.enable = true;
    cache.substituter = true;
    controllers.nintendo.enable = true;
    virtualisation = {
      enable = true;
      passthrough = {
        enable = false;
        ids = [
          "1002:13c0"
          "1002:1640"
        ];
      };
    };
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
