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
    xdg.portal = {
      wlr = {
        settings = {
          screencast = {
            output_name = "DP-3";
            # max_fps = 30;
            # exec_before = "disable_notifications.sh";
            # exec_after = "enable_notifications.sh";
            # chooser_type = "simple";
            # chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
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
