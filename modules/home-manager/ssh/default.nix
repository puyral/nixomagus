{
  is_nixos,
  rootDir,
  lib,
  config,
  ...
}:
with lib;
let
  # preprare_key = key: if is_nixos then key else "command=\". ~/.profile; if [ -n \\\"$SSH_ORIGINAL_COMMAND\\\" ]; then eval \\\"$SSH_ORIGINAL_COMMAND\\\"; else exec \\\"$SHELL\\\"; fi\" ${key}";
  preprare_key = key: key;
  cfg = config.extra.ssh;

in
{
  options.extra.ssh.enable = mkEnableOption "ssh";
  config =
    mkIf cfg.enable

      {
        home.file.".ssh/authorized_keys_source" = {
          text = builtins.concatStringsSep "\n" (
            builtins.map preprare_key (import (rootDir + /secrets/ssh_keys.nix))
          );
          onChange = "cat ~/.ssh/authorized_keys_source > ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys";
        };

        programs.ssh =
          let
            vampire-ip = "100.111.36.99";
            nixomagus-ip = "100.106.190.9";
            amdra-ip = "100.84.31.85";
          in
          {
            enable = true;
            matchBlocks = {
              dynas = {
                hostname = "dynas.puyral.fr";
              };
              vampire = {
                hostname = vampire-ip;
              };
              "vampire-root" = {
                hostname = vampire-ip;
                user = "root";
              };
              nixomagus = {
                hostname = nixomagus-ip;
              };
              amdra = {
                hostname = amdra-ip;
              };
            };
          };
      };
}
