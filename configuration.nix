# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  nixpkgs,
  nixpkgs-unstable,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./filesystem.nix
    ./nvidia.nix
    ./services.nix
    ./sound.nix
    ./bluetooth.nix
    ./kmonad/kmonad.nix
  ];

  programs.gnupg = {
    agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-gnome3;
      # pinentryFlavor = "gnome3";
    };
  };
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  networking.hostName = "nixomagus"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Vienna";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

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

  programs.zsh.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # home-manager.useGlobalPkgs = true; # use global pkgs
  # Define a user account. Don't forget to set a password with ‘passwd’.

  users.groups.nix-config = {
    members = [ "root" ];
  };

  users.users.simon = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "nix-config"
    ]; # Enable ‘sudo’ for the user.
    useDefaultShell = true;
  };
  users.defaultUserShell = pkgs.zsh;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    htop
    git
    tmux
  ];

  # docker
  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  # automount
  services.gvfs.enable = true;
  services.udisks2.enable = true;

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

  # garbage collection
  nix.gc = {
    automatic = true;
    persistent = true;
    dates = "weekly";
    options = "--delete-older-than 15d";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

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

  # to not redownload everything with `r`
  nix.registry = {
    # because of https://github.com/NixOS/nixpkgs/commit/e456032addae76701eb17e6c03fc515fd78ad74f I can't remap `nixpkgs` itself
    gnixpkgs.flake = nixpkgs-unstable // {
      config.allowUnfree = true;
    };
    latest-unstable = {
      from = {
        type = "indirect";
        id = "unstable";
      };
      to = {
        type = "github";
        owner = "NixOS";
        repo = "nixpkgs";
        ref = "nixpkgs-unstable";
      };
    };
    latest-stable = {
      from = {
        type = "indirect";
        id = "current-stable";
      };
      to = {
        type = "github";
        owner = "NixOS";
        repo = "nixpkgs";
        ref = "nixos-23.11";
      };
    };
  };

  # better caching
  nix.settings.substituters = [
    "https://aseipp-nix-cache.global.ssl.fastly.net"
    "https://cache.nixos.org/"
    "https://nix-community.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  # networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}
