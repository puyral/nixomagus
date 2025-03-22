{
  config,
  pkgs,
  home,
  lib,
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
    programs.zsh = {
      enable = true;
      history = {
        size = 100000;
        path = "$HOME/.cache/zsh/history";
        share = true;
      };
      syntaxHighlighting = {
        enable = true;
      };
      autosuggestion = {
        enable = true;
      };
      enableCompletion = true;

      # oh-my-zsh = {
      #   enable = true;
      #   plugins = [ "git" ];
      # };

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

      initExtra = ''
        ${builtins.readFile ./initExtra.zsh}
        ${builtins.readFile ./checkConfigStatus.zsh}
      '';
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
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

    programs.pay-respects = {
      enable = true;
      enableZshIntegration = true;
    };

    extra.gitConfigFetcher.enable = true;
  };
}
