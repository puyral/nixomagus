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
    ./kmonad
    ./nvidia.nix
    ./hardware-configuration.nix
    ../commun/sound.nix
    ../commun/bluetooth.nix
    kmonad.nixosModules.default
    ./gui.nix
  ];

  fonts.packages = with pkgs; [
    nerdfonts
    fira-code
  ];

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

  # v4l2loopback
  # Make some extra kernel modules available to NixOS
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback.out ];

  # Activate kernel modules (choose from built-ins and extra ones)
  boot.kernelModules = [
    # Virtual Camera
    "v4l2loopback"
    # Virtual Microphone, built-in
    "snd-aloop"
  ];

  # Set initial kernel module settings
  boot.extraModprobeConfig = ''
    # exclusive_caps: Skype, Zoom, Teams etc. will only show device when actually streaming
    # card_label: Name of virtual camera, how it'll show up in Skype, Zoom, Teams
    # https://github.com/umlaeute/v4l2loopback
    options v4l2loopback exclusive_caps=1 card_label="Virtual Camera"
  '';

  programs.gnupg.agent.pinentryPackage = pkgs.pinentry-gnome3;

  nix.buildMachines = [
    # vampire
    {
      hostName = "root@10.250.2.101";
      system = "x86_64-linux";
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
      maxJobs = 4;
    }
    # dynas
    {
      hostName = "simon@10.250.2.2";
      system = "x86_64-linux";
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
      maxJobs = 2;
    }
  ];

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
