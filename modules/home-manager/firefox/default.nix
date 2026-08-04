{
  config,
  lib,
  pkgs-unstable,
  ...
}:
with lib;
let
  cfg = config.extra.firefox;
in
{
  options.extra.firefox.enable = mkEnableOption "firefox";
  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      package = pkgs-unstable.firefox;
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = [ "firefox.desktop" ];
        "text/xml" = [ "firefox.desktop" ];
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
        "x-scheme-handler/about" = [ "firefox.desktop" ];
        "x-scheme-handler/unknown" = [ "firefox.desktop" ];
        "application/xhtml+xml" = [ "firefox.desktop" ];
      };
    };

    home.sessionVariables = {
      DEFAULT_BROWSER = "${pkgs-unstable.firefox}/bin/firefox";
      BROWSER = "firefox";
    };
  };
}
