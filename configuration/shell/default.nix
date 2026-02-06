{ pkgs, lib, nixos-shell, mconfig, ... }: {
  imports = [
    nixos-shell.nixosModules.nixos-shell
  ];

  # Disable bootloader
  boot.loader.systemd-boot.enable = lib.mkForce false;
  
  # Disable NetworkManager
  networking.networkmanager.enable = lib.mkForce false;
  
  # Disable other potentially conflicting services
  services.gvfs.enable = lib.mkForce false;
  services.udisks2.enable = lib.mkForce false;
  
  # nixos-shell config
  nixos-shell.mounts = {
    mountHome = false;
    mountNixProfile = false;
    cache = "none";
  };
  
  # Ensure we have a shell and some basic tools
  environment.systemPackages = with pkgs; [ 
    git
    vim
  ];
  
  environment.shellInit = ''
    if [ -d /cwd ]; then
      cd /cwd
    fi
  '';

  system.stateVersion = mconfig.nixos;
}
