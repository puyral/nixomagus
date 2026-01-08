{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.extra.autoBackup.toRemote;

  # Helper to sanitize systemd service names (replace / with -)
  sanitize = name: builtins.replaceStrings [ "/" ] [ "-" ] name;

  mkName = dataset: "push-${sanitize dataset}";
  sshKey = config.services.syncoid.sshKey;

  serviceName = dataset: "syncoid-${mkName dataset}.service";
  transferServices = map serviceName cfg.datasets;

  unlock-service = "syncoid-push-unlock";
  lock-service = "syncoid-push-lock";
in
{
  options.extra.autoBackup.toRemote = {
    enable = lib.mkEnableOption "encrypted push backup to remote";

    localBaseDataset = lib.mkOption {
      type = lib.types.str;
      description = "The local ZFS parent dataset (e.g. zpool/safe/data)";
      example = "zpool/safe/data";
    };

    remoteDevice = lib.mkOption {
      type = lib.types.str;
      description = "SSH connection string (e.g. root@100.64.0.5)";
    };

    remoteBaseDataset = lib.mkOption {
      type = lib.types.str;
      description = "The REMOTE parent dataset which holds the encryption key (e.g. tank/encrypted-backup)";
    };

    passPhraseFile = lib.mkOption {
      type = lib.types.externalPath;
      description = "Path to the file containing the passphrase for the REMOTE dataset";
    };

    datasets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "List of child datasets to backup (e.g. ['containers' 'home'])";
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {

    # 1. Define the Syncoid Jobs
    services.syncoid = {

      # We map over the list of datasets to create a command for each one
      commands = builtins.listToAttrs (
        map (dataset: {
          name = mkName dataset;
          value = {
            source = "${cfg.localBaseDataset}/${dataset}";
            target = "${cfg.remoteDevice}:${cfg.remoteBaseDataset}/${dataset}";

            # The "Mirror" Strategy
            extraArgs = [
              "--delete-target-snapshots"
              "--no-privilege-elevation"
              "--source-bwlimit=10m"
            ];

            # STRATEGY: Inherit Encryption + Never Mount
            # -x encryption: strips local encryption so it inherits remote parent's encryption
            # -o canmount=off: prevents the remote from ever mounting this dataset
            recvOptions = "-x encryption -o canmount=off";

            service = {
              serviceConfig = {
                Type = "oneshot";
              };
              requires = [ "${unlock-service}.service" ];
              after = [ "${unlock-service}.service" ];
              # deactivate timer
              startAt = lib.mkForce [ ];
            };
          };
        }) cfg.datasets
      );
    };

    systemd.services = {
      # 2. The UNLOCKER (The Prerequisite)
      # Triggered automatically because Transfer services Require it.
      "${unlock-service}" = {
        description = "Unlock Remote Dataset: ${cfg.remoteDevice}:${cfg.remoteBaseDataset}";
        serviceConfig = {
          Type = "oneshot";
          PermissionsStartOnly = true;
          User = "root";
        };
        script = ''
          echo "Checking encryption state..."
          STATUS=$(${pkgs.openssh}/bin/ssh -i ${sshKey} \
            -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
            ${cfg.remoteDevice} "zfs get -H -o value keystatus ${cfg.remoteBaseDataset}")

          if [ "$STATUS" = "unavailable" ]; then
            echo "Key unavailable. Unlocking..."
            cat ${cfg.passPhraseFile} | \
              ${pkgs.openssh}/bin/ssh -i ${sshKey} \
              -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
              ${cfg.remoteDevice} "zfs load-key -L prompt ${cfg.remoteBaseDataset}"
          fi
        '';
      };

      # 3. The CONTROLLER (The Locker)
      # This is what the Timer actually starts.
      "${lock-service}" = {
        description = "Lock Remote Dataset: ${cfg.remoteDevice}:${cfg.remoteBaseDataset}";

        # DEPENDENCY MAGIC:
        # "Wants": Starts these services when I start. (Wants allows them to fail without failing me)
        # "After": I won't run my Script until they have ALL finished (exit status).
        wants = transferServices;
        after = transferServices;

        serviceConfig = {
          Type = "oneshot";
          User = config.services.syncoid.user;
        };

        # This runs only when all backups are done.
        script = ''
          echo "All transfers finished. Locking remote dataset..."
          ${pkgs.openssh}/bin/ssh -i ${sshKey} \
            -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
            ${cfg.remoteDevice} "zfs unload-key ${cfg.remoteBaseDataset}" || true
        '';
      };
    };

    # 5. The TRIGGER
    # Only triggers the Lock service (which starts the chain)
    systemd.timers."${lock-service}" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = config.services.syncoid.interval;
        Persistent = true;
        Unit = "${lock-service}.service";
      };
    };
  };
}
