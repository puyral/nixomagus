{config, lib, mangowc, pkgs,  ...}:
let cfg = config.extra.mangowc; in {
  imports = [mangowc.hmModules.mango];

  options.extra.mangowc.enable = lib.mkEnableOption "mangowc";

  config = lib.mkIf cfg.enable  {
    wayland.windowManager.mango = {
      enable = true;
    };
    home.packages = with pkgs; [
      foot rofi
    ];
  };
}