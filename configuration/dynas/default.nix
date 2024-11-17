{ pkgs, ... }:
{
  imports = [
    ./filesystem.nix
    ./hardware-config.nix
    ./services
    ./firewall.nix
    ./usersNgroups.nix
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
}
