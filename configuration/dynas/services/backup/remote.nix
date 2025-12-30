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
            ];

            # STRATEGY: Inherit Encryption + Never Mount
            # -x encryption: strips local encryption so it inherits remote parent's encryption
            # -o canmount=off: prevents the remote from ever mounting this dataset
            recvOptions = "-x encryption -o canmount=off";
          };
        }) cfg.datasets
      );
    };

    # 2. Define the Systemd Hooks (Unlock -> Start -> Lock)
    # We iterate over the same list to inject preStart/postStop into the generated services
    systemd.services = builtins.listToAttrs (
      map (dataset: {
        name = "syncoid-${mkName dataset}";
        value = {
          serviceConfig = {
            # FIX: Prevent 200/CHDIR error by starting in the root directory
            # WorkingDirectory = "/run/syncoid/${mkName dataset}";
            # RuntimeDirectoryMode = lib.mkForce "0755";
            InaccessiblePaths = lib.mkForce [ ];
          };
          # Hook 1: Unlock the PARENT on the remote before starting
          preStart = ''
            echo "Unlocking remote parent dataset: ${cfg.remoteBaseDataset}..."
            cat ${cfg.passPhraseFile} | \
              ${pkgs.openssh}/bin/ssh -i ${sshKey} \
              -o StrictHostKeyChecking=no \
              -o UserKnownHostsFile=/dev/null \
              ${cfg.remoteDevice} \
              "zfs load-key -L prompt ${cfg.remoteBaseDataset}"
          '';

          # Hook 2: Lock the PARENT on the remote after finishing (success or failure)
          postStop = ''
            echo "Locking remote parent dataset: ${cfg.remoteBaseDataset}..."
            ${pkgs.openssh}/bin/ssh -i ${sshKey} \
              -o StrictHostKeyChecking=no \
              -o UserKnownHostsFile=/dev/null \
              ${cfg.remoteDevice} \
              "zfs unload-key ${cfg.remoteBaseDataset}" || true
          '';
        };
      }) cfg.datasets
    );
  };
}
