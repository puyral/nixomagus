{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.extra.yazi;
in
{
  options.extra.yazi = with lib; {
    enable = mkEnableOption "yazi";
  };

  config = lib.mkIf cfg.enable {
    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
      shellWrapperName = "yy";
    };
    home.packages = with pkgs; [ ueberzugpp ];

    programs.tmux.extraConfig = ''
      set -g allow-passthrough on
      set -ga update-environment TERM
      set -ga update-environment TERM_PROGRAM
    '';
  };
}
