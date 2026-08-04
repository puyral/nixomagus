{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.extra.gui;
in
{
  imports = [ ];

  config = lib.mkIf (cfg.enable && cfg.mangowc) {

    programs.mango = {
      enable = true;
    };
    extra.gui.extraWlrInUse = [ "mango" ];

    environment.systemPackages = with pkgs; [
      slurp
      grim
    ];

    xdg.portal.wlr = {
      enable = true;
      settings = {
        screencast = {
          chooser_type = "simple";
          chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
        };
      };
    };
  };
}
