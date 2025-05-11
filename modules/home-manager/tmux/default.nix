{pkgs, config,  lib, ...}: let cfg = config.extra.tmux; in
{
  options.extra.tmux = with lib; {
    enable = mkEnableOption "tmux";
  };

  config = lib.mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      clock24 = true;
      mouse = true;
      keyMode = "vi";
      historyLimit = 5000;
    };
  };
}