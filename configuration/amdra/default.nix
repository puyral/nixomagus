{
  # kmonad,
  pkgs,
  pkgs-unstable,
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

  boot.kernelPackages = pkgs-unstable.linuxPackages_zen;
  boot.zfs.package = pkgs-unstable.zfs_2_4; # and zfs
  vars.kernel = config.boot.kernelPackages;

  extra = {
    splash_screen.enable = false;
    v4l2loopback.enable = true;
    # keyboard.enable = true;
    cache.substituter = false;
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
      jetbrains-mono
      roboto # The font you specifically wanted
      noto-fonts # The default font used in the template
      # noto-fonts-cjk # Good to have for fallback characters
      # noto-fonts-emoji
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
