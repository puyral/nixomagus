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

  extra.cachefilesd.enable = true;
  fileSystems =
    let
      zeno = {
        device = "${dynas-ip}:/mnt/Zeno";
        fsType = "nfs";
        options = [
          "x-systemd.automount"
          "noauto"
          "nofail"
          "x-systemd.idle-timeout=60"
          # "fsc"
        ];
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

      "${config.extra.cachefilesd.cacheDir}" = {
        label = "NIXROOT";
        fsType = "btrfs";
        options = [
          "subvol=cache"
          "compress=zstd"
          "noatime"
        ];

      };

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
