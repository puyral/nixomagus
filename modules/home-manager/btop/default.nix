{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.extra.btop;
in
{
  options.extra.btop = with lib; {
    enable = mkEnableOption "btop";
  };

  config = lib.mkIf cfg.enable {
    programs.btop = {
      enable = true;
    };
  };
}
