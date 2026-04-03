{
  pkgs,
  lib,
  ...
}:
{
  imports = [
  ];

  # Disable things from commun that we don't need or want
  extra.tailscale.enable = lib.mkForce false;
  extra.mail.enable = lib.mkForce false;
  extra.nix-ld.enable = lib.mkForce false;
  programs.gnupg.agent.enable = lib.mkForce false;

  # nix.optimise.automatic conflicts with writableStoreOverlay
  nix.optimise.automatic = lib.mkForce false;
  nix.settings.auto-optimise-store = lib.mkForce false;

  # MicroVM configuration
  microvm = {
    hypervisor = "qemu";
    writableStoreOverlay = "/nix/.rw-store";
    
    # Increase RAM and enable ballooning
    mem = 4000;
    vcpu = 4;
    balloon = true; # It expects a boolean, not a set

    # Populate the guest Nix DB with the system closure at boot.
    # This fixes Home Manager and allows nix commands to work.
    registerClosure = true;

    # Bypass mkfs.erofs by using a share for the store
    storeOnDisk = false;

    # Use 9p for the store share
    shares = [
      {
        source = "/nix/store";
        mountPoint = "/nix/store";
        tag = "ro-store";
        proto = "9p";
      }
    ];

    # Networking: User-mode (SLIRP)
    interfaces = [ {
      type = "user";
      id = "eth0";
      mac = "02:00:00:00:00:01";
    } ];

    # Empty volumes list to avoid mkfs calls
    volumes = [ ];
  };

  # Use tmpfs for root
  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "relatime" "mode=755" "size=4G" ];
  };

  # Force /nix/store to use 9p
  fileSystems."/nix/store" = {
    device = "ro-store";
    fsType = lib.mkOverride 10 "9p";
    neededForBoot = true;
    options = [ "ro" "trans=virtio" "version=9p2000.L" "cache=loose" ];
  };

  # Network configuration for the user-mode interface
  networking.useNetworkd = true;
  networking.networkmanager.enable = lib.mkForce false;
  systemd.network.networks."10-eth0" = {
    matchConfig.Name = "eth0";
    networkConfig.DHCP = "yes";
  };

  # Ensure Nix daemon is running and accessible
  nix.enable = true;
  systemd.services."home-manager-simon" = {
    after = [ "nix-daemon.service" "nix-daemon.socket" ];
    wants = [ "nix-daemon.service" ];
  };

  # SSH for easy access
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  # We want a minimal system
  environment.systemPackages = with pkgs; [
    gitMinimal
    vim
    htop
  ];

  # Ensure simon has the right groups
  users.users.simon.extraGroups = [ "wheel" ];
  
  # Allow root login without password for convenience in the sandbox
  users.users.root.initialPassword = "";
  security.sudo.wheelNeedsPassword = false;
}
