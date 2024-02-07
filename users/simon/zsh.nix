{ config, pkgs, home,... }:
{
  imports = [ ./starship.nix ];

  programs.zsh = {
    enable = true;
    history = {
      size = 100000;
      path = "/home/simon/.cache/zsh/history";
      share = true;
    };
    syntaxHighlighting = {
      enable = true;
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git"];
    };

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
  };
}
