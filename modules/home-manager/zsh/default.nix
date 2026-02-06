{
  config,
  pkgs,
  home,
  lib,
  pkgs-self,
  ...
}:
with lib;
let
  cfg = config.extra.zsh;
in
{
  # imports = [ ../starship.nix ];
  options.extra.zsh = {
    enable = mkEnableOption "zsh";
  };
  config = mkIf cfg.enable {
    home.packages = [ pkgs-self.sss ];

    programs.zsh = {
      enable = true;
      history = {
        size = 100000;
        path = "$HOME/.cache/zsh/history";
        share = true;
      };

      autocd = true;
      syntaxHighlighting = {
        enable = true;
      };
      autosuggestion = {
        enable = true;
      };
      enableCompletion = true;

      plugins = [
        {
          name = "zsh-nix-shell";
          file = "nix-shell.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "chisui";
            repo = "zsh-nix-shell";
            rev = "v0.8.0";
            sha256 = "1lzrn0n4fxfcgg65v0qhnj7wnybybqzs4adz7xsrkgmcsr0ii8b7";
          };
        }
      ];

      initContent = ''
        ${builtins.readFile ./initExtra.zsh}
        ${builtins.readFile ./checkConfigStatus.zsh}
      '';
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      tmux = lib.mkIf config.extra.tmux.enable {
        enableShellIntegration = true;
      };
    };

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [ "--cmd cd" ];
    };

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.nix-index = {
      enable = true;
    };

    extra.gitConfigFetcher.enable = true;

    home.sessionVariables = {
      CONFIG_LOCATION = config.extra.nix.configDir;
    };
  };
}
