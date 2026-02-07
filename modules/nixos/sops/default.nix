{
  lib,
  config,
  rootDir,
  ...
}:

let
  cfg = config.extra.sops;
in
{
  options.extra.sops.enable = lib.mkOption {
    default = true;
    type = lib.types.bool;
    description = "Wether to enable sops";
  };

  config = (
    lib.mkIf cfg.enable {
      sops.defaultSopsFile = ../../../.sops.yaml;
      # This will automatically import SSH keys as age keys
      sops.age.sshKeyPaths = [
        "/etc/ssh/ssh_host_ed25519_key"
        # "/etc/ssh/ssh_host_ed25519_key-2"
      ];
      # # This is using an age key that is expected to already be in the filesystem
      # sops.age.keyFile = "/var/lib/sops-nix/key.txt";
      # # This will generate a new key if the key specified above does not exist
      # sops.age.generateKey = true;
    }
  );
}
