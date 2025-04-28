{ pkgs, lib, ... }:
{
  imports = [
    ./zfs.nix
    # ../commun/filesystem.nix
  ];
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/0afeaab9-e25b-4ee9-b611-659ebd52a33d";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/B8CE-5FA8";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };
  swapDevices = [ ];
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = lib.mkDefault "70%";
}
