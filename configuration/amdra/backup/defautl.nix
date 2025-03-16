{ config, pkgs, ... }:
let
  vdevs = [
    {
      from = "Zeno/media/photos";
      to = "Backup/photos";
    }
  ];

in

{
  systemd.services.zfs-backup = {
    description = "Weekly ZFS Backup Service";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.coreutils}/bin/bash /usr/local/bin/zfs-backup.sh";
      User = "simon";
    };
  };

  systemd.timers.zfs-backup = {
    description = "Weekly ZFS Backup Timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = "true";
    };
  };
}
