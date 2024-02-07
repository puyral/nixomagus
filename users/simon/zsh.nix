{ config, pkgs, ... }:
{
  imports = [ ];

  programs.zsh = {
    enable = true;
    histSize = 100000;
    histFile = "$(home.homeDIrectory)/.cache/zshhist";

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "thefuck" ];
      theme = "robbyrussell";
    };
  };
}
