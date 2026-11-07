{
  lib,
  pkgs,
  pkgs-unstable,
  pkgs-self,
  ...
}:
{
  home = {
    packages =
      (with pkgs; [ python3 ])
      ++ (with pkgs-unstable; [ nodejs ])
      ++ [
        pkgs-self.pi-subagent-control
        pkgs-self.git-worktree-hook-maker
      ];
    sessionPath = [ "$HOME/.npm-global/bin" ];

    file.".pi/agent/bin/find".source = lib.getExe pkgs-self.jailedFind;
    file.".pi/agent/bin/grep".source = lib.getExe pkgs-self.jailedGrep;
  };

  # Minimal home-manager config for the sandbox
  # imports = [ ./commun ]; # already imported by users/simon/default.nix
  extra = {
    jail.enable = true;

    llm-clients = {
      enable = true;
    };
  };
  programs.git.settings = {
    safe.directory = lib.mkForce "/mnt/host";
  };
  programs.gh.enable = lib.mkForce false;

  programs.direnv.config = {
    whitelist.prefix = [
      "/home/simon/.pi-subagents"
      "/home/simon/extra-worktree"
    ];
  };

  services.pi-ops = {
    enable = true;
    direnv.enable = true;
    piHome = "/home/simon";
    port = 9456;
  };
}
