{ config, lib, ... }:
let
  cfg = config.extra.mail-server.remoteStorage;
  enable = config.extra.mail-server.enable && cfg.enable;
in

{
  config = lib.mkIf enable {
    fileSystems."${config.local.base}" = {
      device = "${cfg.remote.ip}:${cfg.remote.path}"; # NAS Tailscale IP : Path on NAS
      fsType = "nfs";
      # see https://doc.dovecot.org/2.3/configuration_manual/nfs/
      options = [
        "actimeo=60"
        "rw"
        "noatime"
        "hard" # "hard" is safer for mail: if NAS dies, the app waits (hangs) rather than corrupting data
        "nofail"
        "noauto"
        "nordirplus"
      ];
    };

    mailserver = {
      mailDirectory = "${config.local.storage}";
      useFsLayout = true;
    };

    services.dovecot2.extraConfig = ''
      mmap_disable = yes
      mail_fsync = always
    '';
  };

  # # CRITICAL: Do not start the mailserver until the mount is ready
  # systemd.services.postfix.after = [ "var-vmail.mount" ];
  # systemd.services.dovecot2.after = [ "var-vmail.mount" ];
}
