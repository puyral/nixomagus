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
  programs.gnupg.agent.enable = lib.mkForce false;

  # Network configuration for the user-mode interface
  networking.useNetworkd = true;
  networking.networkmanager.enable = lib.mkForce false;
  networking.firewall.allowedTCPPorts = [ 22 ];

  nix = {
    enable = true;
  };

  # SSH for easy access
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

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
  # users.users.root.initialPassword = "";
  security.sudo.wheelNeedsPassword = false;
}
