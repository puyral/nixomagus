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

  config = lib.mkIf (cfg.enable && cfg.i3) {

    services.xserver.windowManager.i3 = {
      package = pkgs.i3-gaps;
      enable = true;
    };
  };
}
