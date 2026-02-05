{ lib, config, ... }:
with lib;
{
  options.extra.sway = {
    enable = mkEnableOption "sway";
  };
}
