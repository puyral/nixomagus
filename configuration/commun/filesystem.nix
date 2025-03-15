{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  fileSystems =
    let
      mkfs =
        subvol:
        {
          extraOptions ? [ ],
          compress ? "zstd",
          ...
        }:
        {
          label = "NIXROOT";
          fsType = "btrfs";
          options = [
            "subvol=${subvol}"
            "compress=${compress}"
          ] ++ extraOptions;
        };

    in
    {
      "/mnt/btrfs-root" = {
        label = "NIXROOT";
        fsType = "btrfs";
      };
      "/" = mkfs "root" { };
      "/home" = mkfs "home" { };
      "/nix" = mkfs "nix" { extraOptions = [ "noatime" ]; };
      "/config" = mkfs "config" { compress = "zlib"; };
    };

  boot.supportedFilesystems = [ "ntfs" ];
  # see https://discourse.nixos.org/t/nixos-install-with-custom-flake-results-in-boot-being-world-accessible/34555/3

  # tmp
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = lib.mkDefault "70%";
  services.btrfs = {
    autoScrub.enable = true;
  };
}
