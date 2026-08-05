{
  config,
  lib,
  pkgs,
  pkgs-self,
  ...
}:
let
  cfg = config.extra.mangowc;

  coestr = with lib; types.coercedTo types.int toString types.str;
  coeListOf = with lib; t: types.coercedTo t (x: [ x ]) (types.listOf t);
in
{
  imports = [
    ./waybar
    ./settings.nix
  ];

  options.extra.mangowc = with lib; {
    enable = mkEnableOption "mangowc";
    monitors = mkOption {
      type = with types; coeListOf (attrsOf coestr);
    };
  };

  config = lib.mkIf cfg.enable {
    # The portal daemon only scans the first portal dir found in XDG_DATA_DIRS,
    # which (because the hyprland home-manager module installs its portal into
    # home.packages) is the home-manager user profile. The system-wide portal
    # backends in /run/current-system are shadowed and never loaded, so mangowc
    # ends up with no backends (no OpenURI, no ScreenCast). Install the backends
    # mangowc needs into the home profile too.
    home.packages = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];

    extra = {
      wallpaper.enable = true;
      anyrun.enable = true;
    };
    wayland.windowManager.mango = {
      enable = true;
      package = pkgs-self.mango;
      systemd = {
        enable = true;
        xdgAutostart = true;
        extraCommands = [
          "systemctl --user start wallpaper.target"
        ];
      };
      autostart_sh =
        let
          mango_c = "${config.xdg.configHome}/mango";
        in
        ''
          ${pkgs-self.waybar}/bin/waybar -s ${mango_c}/waybar/style.css -c ${mango_c}/waybar/config.jsonc;
        '';
    };

    # Automatically start the wallpaper target whenever the mango session starts
    systemd.user.targets.mango-session.Unit = {
      Wants = [ "${config.vars.wallpaperTarget}" ];
      After = [ "${config.vars.wallpaperTarget}" ];
    };
  };

}
