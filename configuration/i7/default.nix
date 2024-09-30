{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./gui.nix
  ];
  services.openssh = {
    settings = {
      X11Forwarding = true;
    };
  };
  programs.gnupg.agent.pinentryPackage = pkgs.pinentry-gnome3;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;


  nix.distributedBuilds = false;

    nix.buildMachines = [
    # vampire
    # {
    #   hostName = "root@10.250.2.101";
    #   system = "x86_64-linux";
    #   supportedFeatures = [
    #     "nixos-test"
    #     "benchmark"
    #     "big-parallel"
    #     "kvm"
    #   ];
    #   maxJobs = 4;
    # }
    # dynas
    {
      hostName = "simon@dynas.puyral.fr";
      system = "x86_64-linux";
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
      maxJobs = 2;
    }
  ];
}
