{
  pkgs,
  lib,
  ...
}:
{
  boot.isContainer = true;
  boot.loader.systemd-boot.enable = lib.mkForce false;

  # Networking
  networking.useNetworkd = true;
  networking.useDHCP = false;
  networking.firewall.enable = false;
  networking.networkmanager.enable = lib.mkForce false;

  # Resolv conf issues in containers
  services.resolved.enable = lib.mkForce false;
  networking.useHostResolvConf = lib.mkForce true;

  # Autologin into it as "simon"
  services.getty.autologinUser = "simon";

  # Ensure simon has the right groups
  users.users.simon.extraGroups = [ "wheel" ];

  # Allow root login without password for convenience
  users.users.root.initialPassword = "";
  security.sudo.wheelNeedsPassword = false;

  # Minimal packages
  environment.systemPackages = with pkgs; [
    vim
    htop
    gitMinimal
    ps
  ];

  # Nix configuration
  nix = {
    enable = true;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "simon" ];
    };
  };

  system.stateVersion = "25.11";
}
