{...}:{
  home.file.".ssh/authorized_keys".text = builtins.concatStringsSep "\n" (import ./ssh_keys.nix);

  programs.ssh = {
    enable = true;
    matchBlocks = {
      dynas = {
        hostname = "dynas.puyral.fr";
      };
    };
  };
}