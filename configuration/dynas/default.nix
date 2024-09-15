{ pkgs, ... }:
{
  imports = [
    ./filesystem.nix
    ./hardware-config.nix
    ./services
  ];

  #users.mutableUsers = false;
  #users.users.simon.hashedPassword = "$y$j9T$eCgQtUivc7Amusroh6.uZ0$yzhpWtfMKNqmAmQRirHkfCvc2LOIlbgAKaDYnEWOSw5";
}
