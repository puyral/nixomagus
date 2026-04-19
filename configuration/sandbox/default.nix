{
  pkgs,
  lib,
  # microvm,
  nixpkgs,
  ...
}:
{
  imports = [
    # microvm.nixosModules.microvm
    "${nixpkgs}/nixos/modules/virtualisation/incus-virtual-machine.nix"
  ];

  # Disable things from commun that we don't need or want
  extra.tailscale.enable = lib.mkForce false;
  extra.mail.enable = lib.mkForce false;

  # because libgit2 is broken in VM, I use lix
  # see https://lix.systems/add-to-config/
  nixpkgs.overlays = [
    (final: prev: {
      inherit (prev.lixPackageSets.stable)
        nixpkgs-review
        nix-eval-jobs
        nix-fast-build
        colmena
        ;
    })
  ];
  nix.package = pkgs.lixPackageSets.stable.lix;

  programs.gnupg.agent.enable = lib.mkForce false;

  # Network configuration for the user-mode interface
  networking.useNetworkd = true;
  networking.networkmanager.enable = lib.mkForce false;

  nix = {
    enable = true;
  };

  # SSH for easy access
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
    openFirewall = true;
  };

  # We want a minimal system
  environment.systemPackages = with pkgs; [
    vim
    htop
  ];

  zramSwap.enable = true;

  # Ensure simon has the right groups
  users.users.simon.extraGroups = [ "wheel" ];
  services.getty.autologinUser = "simon";

  # Allow root login without password for convenience in the sandbox
  # users.users.root.initialPassword = "";
  security.sudo.wheelNeedsPassword = false;
}
