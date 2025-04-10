{ pkgs, ... }:
{
  imports = [
    ./filesystem.nix
    ./hardware-config.nix
    ./services
    ./firewall.nix
    ./usersNgroups.nix
    ./power_management.nix
    ./networking.nix
  ];
  extra = {
    mail.enable = true;
    cache.substituter = false;
  };
  programs.gnupg.agent.pinentryPackage = pkgs.pinentry-curses;

  # docker
  virtualisation.docker = {
    enable = true;
  };
}
