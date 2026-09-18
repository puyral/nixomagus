{
  lib,
  pkgs,
  pkgs-unstable,
  pkgs-self,
  ...
}:
{
  home.packages =
    (with pkgs; [ python3 ]) ++ (with pkgs-unstable; [ nodejs ]) ++ [ pkgs-self.pi-subagent-control ];
  home.sessionPath = [ "$HOME/.npm-global/bin" ];
  # Minimal home-manager config for the sandbox
  # imports = [ ./commun ]; # already imported by users/simon/default.nix
  extra = {
    jail.enable = true;

    llm-clients = {
      enable = true;
      lean.enable = true;
      mcp-nix.enable = true;
      lspranto.enable = true;
    };
  };
  programs.git.settings = {
    safe.directory = lib.mkForce "/mnt/host";
  };
  programs.gh.enable = lib.mkForce false;

  programs.direnv.config = {
    whitelist.prefix = [ "/home/simon/.pi-subagents" ];
  };
}
