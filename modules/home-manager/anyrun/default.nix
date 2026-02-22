{ config, lib, ... }:
let
  cfg = config.extra.anyrun;
in
{
  options.extra.anyrun = {
    enable = lib.mkEnableOption "anyrun";
  };
  config = lib.mkIf cfg.enable {
    programs.anyrun = {
      enable = true;
      config = {
        closeOnClick = true;
        hidePluginInfo = true;
      };
    };
  };
}
