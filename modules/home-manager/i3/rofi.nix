{ config, lib, ... }:
with lib;
let
  cfg = config.extra.i3;
in
{
  programs.rofi = mkIf cfg.enable {
    enable = true;
    theme = ./rofi-theme.rasi;
  };
}
