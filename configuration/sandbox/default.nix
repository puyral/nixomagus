{
  pkgs,
  lib,
  microvm,
  ...
}:
{
  imports = [
    microvm.nixosModules.microvm
  ];

  # Disable things from commun that we don't need or want
  extra.tailscale.enable = lib.mkForce false;
  extra.mail.enable = lib.mkForce false;
  programs.gnupg.agent.enable = lib.mkForce false;

  # nix.optimise.automatic conflicts with writableStoreOverlay

  # MicroVM configuration
  microvm = {
    hypervisor = "qemu";
    writableStoreOverlay = "/nix/.rw-store";

    # Increase RAM and enable ballooning
    mem = 4000;
    vcpu = 4;
    balloon = true; # It expects a boolean, not a set

    shares = [
      {
        tag = "ro-store";
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
        proto = "9p";
      }

    ];

    # Networking: User-mode (SLIRP)
    interfaces = [
      {
        type = "user";
        id = "eth0";
        mac = "02:00:00:00:00:01";
      }
    ];

    forwardPorts = [
      {
        from = "host";
        host.port = 2222;
        guest.port = 22;
      }
    ];
  };

  fileSystems = {
    "/.share" = {
      device = "host-pwd";
      fsType = "9p";
      options = [
        "trans=virtio"
        "version=9p2000.L"
        "access=any"
        "noauto"
      ];
    };
    "/share" = {
      device = "/.share";
      fsType = "fuse.bindfs";
      options = [
        "map=0/1000:@0/@1000"
        "noauto"
        "x-systemd.automount"
      ];
    };
  };

  # Network configuration for the user-mode interface
  networking.useNetworkd = true;
  networking.networkmanager.enable = lib.mkForce false;
  networking.firewall.allowedTCPPorts = [ 22 ];
  # systemd.network.networks."10-eth0" = {
  #   matchConfig.Name = "eth0";
  #   networkConfig.DHCP = "yes";
  # };

  nix = {
    enable = true;

    optimise.automatic = lib.mkForce false;
    gc.automatic = lib.mkForce false;
  };

  # SSH for easy access
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  # Autologin into it as "simon"
  services.getty.autologinUser = "simon";

  # We want a minimal system
  environment.systemPackages = with pkgs; [
    # gitMinimal
    vim
    htop
    bindfs
  ];

  # Ensure simon has the right groups
  users.users.simon.extraGroups = [ "wheel" ];

  # Allow root login without password for convenience in the sandbox
  users.users.root.initialPassword = "";
  security.sudo.wheelNeedsPassword = false;
}
