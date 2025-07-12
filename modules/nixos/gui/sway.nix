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

  config = lib.mkIf (cfg.enable && cfg.sway) {
    programs = {
      sway = {
        enable = true;
        wrapperFeatures.gtk = true;
        xwayland.enable = true;
      };
      uwsm.enable = true;
    };

  };

}
