{ is_nixos, ... }:
let
  # preprare_key = key: if is_nixos then key else "command=\". ~/.profile; if [ -n \\\"$SSH_ORIGINAL_COMMAND\\\" ]; then eval \\\"$SSH_ORIGINAL_COMMAND\\\"; else exec \\\"$SHELL\\\"; fi\" ${key}";
  preprare_key = key: key;

in

{
  home.file.".ssh/authorized_keys_source" = {
    text = builtins.concatStringsSep "\n" (builtins.map preprare_key (import ./ssh_keys.nix));
    onChange = "cat ~/.ssh/authorized_keys_source > ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys";
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      dynas = {
        hostname = "dynas.puyral.fr";
      };
      vampire = {
        hostname = "10.250.2.101";
      };
      "vampire-root" = {
        hostname = "10.250.2.101";
        user = "root";
      };
    };
  };
}
