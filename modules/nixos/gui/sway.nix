{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.extra.gui;
in
{

  config = lib.mkIf (cfg.enable && cfg.sway) {
    security.polkit.enable = true;
    programs = {
      sway = {
        enable = true;
        wrapperFeatures.gtk = true;
        xwayland.enable = true;
        package = pkgs.swayfx;
      };
      uwsm = {
        enable = true;

        waylandCompositors = {
          sway = {
            prettyName = "Sway";
            comment = "Sway compositor managed by UWSM";
            binPath = "${config.programs.sway.package}/bin/sway";
          };
        };
      };
    };

    #   config = {
    #     sway.default = [
    #       "gtk"
    #       "hyprland"
    #     ];
    #   };
    #   extraPortals = [
    #     pkgs.xdg-desktop-portal-hyprland
    #   ];
    # };

  };

}
