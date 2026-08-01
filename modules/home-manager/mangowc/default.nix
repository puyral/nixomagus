{
  config,
  lib,
  pkgs-self,
  ...
}:
let
  cfg = config.extra.mangowc;

  coestr = with lib; types.coercedTo types.int toString types.str;
  coeListOf = with lib; t: types.coercedTo t (x: [ x ]) (types.listOf t);
  variables = lib.concatStringsSep " " config.wayland.windowManager.mango.systemd.variables;
in
{
  imports = [
    # ./mango-hm.nix
    # ./waybar.nix
    ./settings.nix
  ];

  options.extra.mangowc = with lib; {
    enable = mkEnableOption "mangowc";
    monitors = mkOption {
      type = with types; coeListOf (attrsOf coestr);
    };
  };

  config = lib.mkIf cfg.enable {
    extra = {
      wallpaper.enable = true;
      anyrun.enable = true;
    };
    wayland.windowManager.mango = {
      enable = true;
      systemd = {
        enable = true;
        xdgAutostart = true;
        extraCommands = [
          "systemctl --user start ${config.vars.wallpaperTarget}"
        ];
      };
      autostart_sh = 
        let mango_c = "${config.xdg.configHome}/mango"; in
        ''
        ${pkgs-self.waybar}/bin/waybar -s ${mango_c}/waybar/style.css -c ${mango_c}/waybar/config.jsonc 
      '';
      #         ${config.extra.waybar.configs.mangowc.run}
    };
  xdg = {
    enable = true;
    configFile = {
      "mango/waybar/style.css".source = ./waybar/style.css;
      "mango/waybar/config.jsonc".source = ./waybar/config.jsonc;
    };
  };
  };

}
