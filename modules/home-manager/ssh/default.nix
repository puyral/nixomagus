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
            ips = config.ips;
          in
          {
            enable = true;
            enableDefaultConfig = false;
            settings = (lib.mapAttrs (_: ip: { HostName = ip; }) ips) // {
              "vampire-root" = {
                HostName = ips.vampire;
                User = "root";
              };

              "gitlab.secpriv.tuwien.ac.at" = {
                ProxyJump = "vampire";
              };
            };
          };
      };
}
