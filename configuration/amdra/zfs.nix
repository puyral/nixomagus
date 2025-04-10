{
  config,
  rootDir,
  lib,
  ...
}:
{
  boot = lib.mkIf config.vars.zfs {
    supportedFilesystems = [ "zfs" ];
    zfs = {
      extraPools = [ "Backup" ];
      forceImportRoot = false;
    };
    kernel.sysctl = {
      # "vfs.zfs.l2arc_rebuild_enabled" = 1;
      "vfs.zfs.arc_max" = "1073741824";
    };
  };
  networking.hostId = "007f0201";

  services.smartd = {
    enable = true;
    defaults = {
      monitored = "-a -o on -s (S/../.././02|L/../../1/02)";
    };
    devices =
      let
        zfsDisk = id: { device = "/dev/disk/by-id/${id}"; };
        zfsDisks = [
          # 10TB toshiba
          "wwn-0x5000039b38d17cf2"
        ];
      in
      builtins.map zfsDisk zfsDisks ++ [ ];

    notifications = {
      # test = true;
      mail = {
        sender = config.programs.msmtp.accounts.default.from;
        recipient = (import (rootDir + /secrets/email.nix)).gmail "smart-amdra";
      };
    };
  };
}
