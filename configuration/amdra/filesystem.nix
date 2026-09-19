{
  config,
  lib,
  pkgs,
  modulesPath,
  self,
  ...
}:
let
  use-tailscale = false;
  dynas-config = self.nixosConfigurations.dynas.config;
  dynas-ip = if use-tailscale then "100.64.0.15" else dynas-config.vars.fastIp;
in
{
  imports = [ ../commun/filesystem.nix ];

  extra.cachefilesd.enable = false;
  fileSystems =
    let
      zeno = {
        device = "${dynas-ip}:/mnt/Zeno";
        fsType = "nfs";
        options = [
          "_netdev"
          "x-systemd.automount"
          "noauto"
          "nofail"
          "x-systemd.idle-timeout=60"
          # "fsc"
        ];
      };

      mkfs2 =
        subvol:
        {
          extraOptions ? [ ],
          compress ? "zstd",
          device ? "UUID=0778732f-c09c-4e14-ad2e-ec60b512151f",
          ...
        }:
        {
          inherit device;
          fsType = "btrfs";
          options = [
            "subvol=${subvol}"
            "compress=${compress}"
            "nofail"
            "noatime"
          ]
          ++ extraOptions;
        };
    in
    {
      "/boot" = {
        label = "NIXBOOT";
        fsType = "vfat";
      };

      "/swap" = {
        label = "NIXROOT";
        fsType = "btrfs";
        options = [
          "subvol=swap"
          "noatime"
        ];
      };
      "/containers" = {
        label = "NIXROOT";
        fsType = "btrfs";
        options = [
          "subvol=containers"
          "compress=zstd"
        ];
      };

      "/mnt/Extra/root" = {
        device = "UUID=0778732f-c09c-4e14-ad2e-ec60b512151f";
        fsType = "btrfs";
      };
      "/mnt/Extra/builds" = mkfs2 "@builds" { compress = "zstd:5"; };
      "/mnt/Extra/darktable" = mkfs2 "@darktable" { };
      "/mnt/Extra/games" = mkfs2 "@games" { };
      "/mnt/Extra/incus" = mkfs2 "@incus" { };
      "/mnt/Extra/ai" = mkfs2 "@ai" { };

      # "${config.extra.cachefilesd.cacheDir}" = {
      #   label = "NIXROOT";
      #   fsType = "btrfs";
      #   options = [
      #     "subvol=cache"
      #     "compress=zstd"
      #     "noatime"
      #   ];
      # };

      "/mnt/Steam" = {
        device = "/dev/disk/by-partuuid/0ad6e9a0-941c-4dcf-8d07-5bfe24091184";
        fsType = "ext4";
        options = [
          "rw"
          "nofail"
        ];
      };

      # "/mnt/Windows" = {
      #   device = "/dev/sda3";
      #   fsType = "ntfs-3g";
      #   options = [
      #     "rw"
      #     "uid=1000"
      #     "nofail"
      #   ];
      # };
      "/mnt/Zeno" = zeno;
      "/Volumes/Zeno" = zeno;

    };
  boot.supportedFilesystems = [ "nfs" ];
  swapDevices = [ ]; # [ { device = "/swap/swapfile1"; } ];
  boot.tmp.tmpfsSize = "50%";
}
