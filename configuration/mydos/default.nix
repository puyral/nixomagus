{
  pkgs,
  rootDir,
  nixos-hardware,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    (rootDir + /overlays/jellyfin.nix)
    ./gui.nix
    ./syncthing.nix
  ];
  extra.splash_screen.enable = true;

  extra.refind.enable = true;

  services.openssh = {
    settings = {
      X11Forwarding = true;
    };
  };
  programs.gnupg.agent.pinentryPackage = pkgs.pinentry-gnome3;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  nix.distributedBuilds = true;

  nix.buildMachines = [
    # vampire
    {
      hostName = "root@10.250.2.101";
      system = "x86_64-linux";
      sshKey = "/home/simon/.ssh/id_ed25519";
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
      maxJobs = 4;
    }
    # dynas
    {
      hostName = "dynas.puyral.fr";
      sshUser = "simon";
      sshKey = "/home/simon/.ssh/id_ed25519";
      system = "x86_64-linux";
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        #  "big-parallel"
        "kvm"
      ];
      maxJobs = 2;
    }
  ];
}
