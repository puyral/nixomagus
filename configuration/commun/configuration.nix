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
  computer_name,
  computer,
  mconfig,
  ...
}@attrs:
# general modules that should be into nixos, in oppositions to modules that cleanly extend this config file

{
  imports = [
    # Include the results of the hardware scan.
    # ./services.nix
  ] ++ (if computer_name == "nixomagus" then [ ./gui.nix ] else [ ]);

  programs.gnupg = {
    agent = {
      enable = true;
      # pinentryPackage = pkgs.pinentry-gnome3;
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

  networking.hostName = computer_name; # Define your hostname.
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

  programs.zsh.enable = true;

  # for compatibility
  programs.nix-ld.enable = true;

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
    hashedPasswordFile = "${./secrets/simon}";
  };
  users.defaultUserShell = pkgs.zsh;
  users.mutableUsers = false;
  security.sudo.wheelNeedsPassword = false;

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

  # garbage collection
  nix.gc = {
    automatic = true;
    persistent = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nix.distributedBuilds = true;
  #nix.buildMachines = [
  #  {
  #    hostName = "root@10.250.2.101";
  #    system = "x86_64-linux";
  #    supportedFeatures = [
  #      "nixos-test"
  #      "benchmark"
  #      "big-parallel"
  #      "kvm"
  #    ];
  #    maxJobs = 4;
  #  }
  #];
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
  };

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
  system.stateVersion = mconfig.nixos; # Did you read the comment?
}
