{ config, lib, pkgs-unstable, ... }:
with lib;
let cfg = config.extra.firefox; in
{
  option.extra.firefox.enable = mkEnableOption "firefox";
  config = mkIf cfg.enable
{
  programs.firefox = {
    enable = true;
    package = pkgs-unstable.firefox;
    nativeMessagingHosts = [ pkgs-unstable.firefoxpwa ];
  };
  home.packages = [ pkgs-unstable.firefoxpwa ];
};}
