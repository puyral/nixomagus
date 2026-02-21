{config, lib, mangowc, ...}:

let
  cfg = config.extra.gui;
in
{
  imports = [mangowc.nixosModules.mango];


  config = lib.mkIf (cfg.enable && cfg.mangowc) {

    programs.mango = {
      enable = true;
    };
  };

}