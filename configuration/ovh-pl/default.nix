{ ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  programs.gnupg.agent.pinentryPackage = pkgs.pinentry-curses;

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  networking.domain = "puyral.fr";
  services.openssh.enable = true;
}