{ pkgs, pkgs-unstable, ... }:
{
  programs.firefox = {
    enable = true;
    package = pkgs-unstable.firefox;
    nativeMessagingHosts = [ pkgs-unstable.firefoxpwa ];
  };
  home.packages = [ pkgs-unstable.firefoxpwa ];
}
