{ kmonad, pkgs, ... }:
{

  imports = [
    ./kmonad/kmonad.nix
    ./nvidia.nix
    ./hardware-configuration.nix
    kmonad.nixosModules.default
  ];

  services.isw.enable = true;

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

}
