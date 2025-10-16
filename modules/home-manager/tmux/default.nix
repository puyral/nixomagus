{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.extra.tmux;
in
{
  options.extra.tmux = with lib; {
    enable = mkEnableOption "tmux";
  };

  config = lib.mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      clock24 = true;
      mouse = true;
      historyLimit = 5000;
      sensibleOnTop = true;
      shell = "${pkgs.zsh}/bin/zsh";

      plugins = with pkgs.tmuxPlugins; [
        pain-control
      ];

      extraConfig = ''
        set-environment -g TMUX_FZF_MENU_POPUP 1
      '';
    };
  };
}
