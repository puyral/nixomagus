{config, lib, mangowc, pkgs,  ...}:
let cfg = config.extra.mango; in {
  imports = [mangowc.hmModules.mango];

  options.extra.mango.enable = lib.mkEnableOption "mangowc";

  config = lib.mkIf cfg.enable  {
    wayland.windowManager.mango = {
      enable = true;
    };
    home.packages = with pkgs; [
      foot rofi
    ];
  };
}