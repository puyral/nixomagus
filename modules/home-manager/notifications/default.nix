{lib, config, pkgs, ...}:
let cfg = config.extra.notifications; in 
{
  options.extra.notifications = {
    enable = lib.mkEnableOption "notifications";
  };
  config = lib.mkIf cfg.enable {
    services.dunst = {
      enable = true;
    };
  };
}