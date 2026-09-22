{ pkgs, lib, ... }:
{
  # installed in one command: `nix run github:nix-community/nixos-anywhere -- --flake .#ovh-fr --target-host root@146.59.228.61 --copy-host-keys`

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

}
