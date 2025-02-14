{
  lib,
  config,
  rootDir,
  ...
}:
{
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs = {
    extraPools = [ "Zeno" ];
    forceImportRoot = false;
  };

  # see https://manpages.debian.org/bookworm/zfs-auto-snapshot/zfs-auto-snapshot.8.en.html
  # for more control
  #
  # Zeno/media/videos is excluded
  services.zfs = {
    autoSnapshot = {
      enable = true;
      monthly = 5;
      flags = "-k -p -v --utc";
    };
    autoScrub.enable = true;

    zed = {
      settings = {
        ZED_EMAIL_ADDR = [
          ((import (rootDir + /secrets/email.nix)).gmail "zfs+${config.networking.hostName}")
        ];
        # ZED_EMAIL_ADDR = ["root"];
        # ZED_EMAIL_OPTS = " @ADDRESS@";

        ZED_NOTIFY_INTERVAL_SECS = 3600;
        ZED_NOTIFY_VERBOSE = true;

        # ZED_USE_ENCLOSURE_LEDS = true;
        ZED_SCRUB_AFTER_RESILVER = true;
      };
    };
  };

  services.smartd = {
    enable = true;
    defaults = {
      monitored = "-a -o on -s (S/../.././02|L/../../1/02)";
    };
    devices =
      let
        zfsDisk = id: { device = "/dev/disk/by-id/${id}"; };
        zfsDisks = [
          # ssd
          # "wwn-0x500a0751e608b583-part1"

          # Toshiba 3TB
          "wwn-0x5000039fc0c49a69"
          "wwn-0x5000039fc0c49d0f"
          "wwn-0x5000039fc0c4836a"
          "wwn-0x5000039fc0c49909"

          # seagate 4TB
          "wwn-0x5000c500e8fb38c1"
          "wwn-0x5000c500e8fb3c9a"
          "wwn-0x5000c500e8fb44a1"
          "wwn-0x5000c500e8fb8de4"
          "wwn-0x5000c500e95106dc" # spare

          # 10TB toshiba
          "wwn-0x5000039b38d17cf2"
        ];
      in
      builtins.map zfsDisk zfsDisks ++ [ ];

    notifications = {
      # test = true;
      mail = {
        sender = config.programs.msmtp.accounts.default.from;
        recipient = (import (rootDir + /secrets/email.nix)).gmail "smart";
      };
    };
  };
}
