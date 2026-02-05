{ config, lib, ... }:
{
  imports = [ ./remote.nix ];
  options.extra.autoBackup.enable = lib.mkEnableOption "autobackup";
  config = lib.mkIf config.extra.autoBackup.enable {
    programs.ssh.knownHosts."100.64.0.5" = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICiAYMQJN/7Cl2zOxFkkAr0d79Kr06sn+svscYRQPknm";
    };

    sops.secrets =
      let
        sopsFile = ./ssh.sops-secret.yaml;
        format = "yaml";

      in
      {
        syncoid-ssh-key = {
          inherit sopsFile format;
          key = "private";
          owner = config.services.syncoid.user;
        };

        backup-datase-passphrase = {
          inherit sopsFile format;
          key = "dataset_passphrase";
          owner = config.services.syncoid.user;
        };
      };

    extra.autoBackup.toRemote = {
      localBaseDataset = "Zeno";
      remoteDevice = "root@100.64.0.5";
      remoteBaseDataset = "Data/Backups/dynas";
      passPhraseFile = config.sops.secrets.backup-datase-passphrase.path;
      datasets = [
        "paperless"
        "administratif"
        "containers"
        "documents"
        "work"
        "media/photos/full-export"
      ];
    };

    services.syncoid = {
      enable = true;
      # user = "root"; # Or a dedicated user
      sshKey = config.sops.secrets.syncoid-ssh-key.path;
      interval = "hourly";

      commands =
        let
          mk = dataset: {
            # Syntax: user@host:pool/dataset
            source = "root@100.64.0.5:Data/${dataset}";
            target = "Zeno/backups/citruso/${dataset}";
            recursive = true;

            # IMPORTANT: "sys" is usually required for TrueNAS/FreeBSD targets
            # to properly handle ZFS permission checks over SSH without sudo.
            extraArgs = [
              "--no-privilege-elevation"
              "--delete-target-snapshots"
            ];

            # recvOptions = " -o canmount=off ";

            localTargetAllow = [
              "change-key"
              "compression"
              "create"
              "mount"
              "mountpoint"
              "receive"
              "rollback"

              "destroy"
            ];
          };

          datasets = [
            "containers"
            "home"
            "Partage"
          ];

          citruso =
            with builtins;
            listToAttrs (
              map (name: {
                name = "pull-citruso-${name}";
                value = mk name;
              }) datasets
            );

        in
        citruso // { };
    };

    # Pruning the backup on NixOS so it doesn't grow forever
    services.sanoid = {
      enable = true;
      datasets = {
        "Zeno/backups" = {
          # WE DO NOT SNAPSHOT THE BACKUP
          autosnap = false;

          # BUT WE DO PRUNE IT
          autoprune = true;
          hourly = 48;
          daily = 30;
          monthly = 6;
          recursive = true;
        };
      };
    };
  };
}
