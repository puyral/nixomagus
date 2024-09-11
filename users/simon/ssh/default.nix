{ ... }:
{
  home.file.".ssh/authorized_keys_source" = {
    text = builtins.concatStringsSep "\n" (import ./ssh_keys.nix);
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
    };
  };
}
