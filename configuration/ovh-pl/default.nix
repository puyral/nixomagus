{ pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./services
    ./networking.nix
  ];

  extra.cache.substituter = false;

  programs.gnupg.agent.pinentryPackage = pkgs.pinentry-curses;

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  networking.domain = "puyral.fr";
  services.openssh.enable = true;

  boot.loader.systemd-boot.enable = lib.mkForce false;
}
