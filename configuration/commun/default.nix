{
  lib,
  pkgs,
  computer,
  rootDir,
  ...
}:
let
  computer_name = computer.name;
in

{
  imports = [
    # ./configuration.nix
    # ./filesystem.nix
    ./services
    ./network.nix
  ];

  # https://github.com/V4bel/dirtyfrag
  boot.extraModprobeConfig = ''
    install esp4 /bin/false
    install esp6 /bin/false
    install rxrpc /bin/false
  '';

  programs.gnupg = {
    agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot = {
    enable = if computer.ovh then false else true;
    memtest86.enable = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  networking = {

    hostName = computer_name; # Define your hostname.
    # Pick only one of the below networking options.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    networkmanager = {
      enable = lib.mkDefault true; # Easiest to use and most distros use this by default.
    };
  };

  time.timeZone = "Europe/Vienna";
  programs.zsh.enable = true;
  extra.nix-ld.enable = true;

  users = {
    groups.nix-config = {
      members = [ "root" ];
    };

    users.simon = {
      description = "Simon Jeanteur";
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
        "nix-config"
      ]; # Enable ‘sudo’ for the user.
      useDefaultShell = true;
      hashedPasswordFile = "${./secrets/simon}";
    };
    defaultUserShell = pkgs.zsh;
    mutableUsers = false;
  };
  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    htop
    gitFull
    usbutils
    pciutils
  ];

  # automount
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # garbage collection
  extra.cache.substituter = lib.mkDefault false; # dynas is down

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    openFirewall = true;
    extraConfig = ''
      	    AcceptEnv COLORTERM
      	  '';
  };
  users.users."root".openssh.authorizedKeys.keys = import (rootDir + /secrets/ssh_keys.nix);

  nix = {
    gc = {
      automatic = true;
      persistent = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    optimise = {
      automatic = true;
      persistent = true;
      dates = [ "03:45" ];
    };

    settings.trusted-users = [
      "root"
      "simon"
      "@wheel"
    ];
    buildMachines =
      if true then
        [ ]
      else
        [
          # vampire
          {
            hostName = "root@100.64.0.16";
            system = "x86_64-linux";
            sshKey = "/home/simon/.ssh/id_ed25519";
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
            hostName = "dynas.puyral.fr";
            sshUser = "simon";
            sshKey = "/home/simon/.ssh/id_ed25519";
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

    settings = {
      substituters = [
        "https://cache.nixos.org/"
      ];
    };

    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

  };

  nixpkgs = {
    overlays = [
    ];
    config = {
      allowUnfree = true;
    };
  };

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
  system.stateVersion = computer.stateVersion; # Did you read the comment?
}
