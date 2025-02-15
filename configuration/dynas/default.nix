{ pkgs, ... }:
{
  imports = [
    ./filesystem.nix
    ./hardware-config.nix
    ./services
    ./firewall.nix
    ./usersNgroups.nix
    ./power_management.nix
  ];
  extra.mail.enable = true;
  programs.gnupg.agent.pinentryPackage = pkgs.pinentry-curses;

  # docker
  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
    # rootless = {
    #   enable = true;
    #   setSocketVariable = true;
    # };
  };

  #users.mutableUsers = false;
  #users.users.simon.hashedPassword = "$y$j9T$eCgQtUivc7Amusroh6.uZ0$yzhpWtfMKNqmAmQRirHkfCvc2LOIlbgAKaDYnEWOSw5";

  networking.interfaces.enp10s0.wakeOnLan.enable = true;
  networking.interfaces.enp13s0.wakeOnLan.enable = true;
}
