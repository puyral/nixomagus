{ pkgs, lib, ... }:
{
# how to rescue: https://www.adyxax.org/blog/2023/11/13/recovering-a-nixos-installation-from-a-linux-rescue-image/

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
