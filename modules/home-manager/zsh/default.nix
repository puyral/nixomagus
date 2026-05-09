{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.extra.zsh;
  jailed = config.extra.jail.enable;
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
        ${lib.optionalString (!jailed) (builtins.readFile ./checkConfigStatus.zsh)}
      '';
    };

    programs.direnv.enableZshIntegration = true;
    programs.fzf.enableZshIntegration = true;
    programs.zoxide.enableZshIntegration = true;
  };
}
