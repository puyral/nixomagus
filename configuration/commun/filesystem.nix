{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{

  fileSystems = {
    "/mnt/btrfs-root" = {
      device = "/dev/disk/by-label/NIXROOT";
      fsType = "btrfs";
    };

    "/" = {
      device = "/dev/disk/by-label/NIXROOT";
      fsType = "btrfs";
      options = [
        "subvol=root"
        "compress=zstd"
      ];
    };

    "/home" = {
      device = "/dev/disk/by-label/NIXROOT";
      fsType = "btrfs";
      options = [
        "subvol=home"
        "compress=zstd"
      ];
    };

    "/nix" = {
      device = "/dev/disk/by-label/NIXROOT";
      fsType = "btrfs";
      options = [
        "subvol=nix"
        "compress=zstd"
        "noatime"
      ];
    };

    "/config" = {
      #device = "/dev/disk/by-label/NIXROOT";
      label = "NIXROOT";
      fsType = "btrfs";
      options = [
        "subvol=config"
        "compress=zlib"
      ];
    };

    "/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };
  };

  swapDevices = [ { device = "/swap/swapfile"; } ];
  boot.supportedFilesystems = [ "ntfs" ];
  # see https://discourse.nixos.org/t/nixos-install-with-custom-flake-results-in-boot-being-world-accessible/34555/3

  # tmp
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "70%";
  services.btrfs = {
    autoScrub.enable = true;
  };
}
