{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.extra.alacritty;
in
{
  options.extra.alacritty.enable = mkEnableOption "alaritty";

  config = mkIf cfg.enable {
    programs.alacritty = {
      enable = true;

      settings = {

        window = {
          decorations = "None";
          padding = {
            x = 10;
            y = 10;
          };
          # dynamic_padding = true;
        };

keyboard.bindings = [
  { key = "Enter"; mods = "Control"; chars = "\\x1b[13;5u"; }
];

        font.normal = {
          family = "Hack Nerd Font Mono";
          style = "Regular";
        };

        colors =
          let
            myColors = import ./colors.nix;
            pallette = myColors.mainPallette;
          in
          {
            primary = {
              background = pallette.background;
              foreground = pallette.foreground;
            };
            normal = builtins.mapAttrs (name: value: value.normal) pallette.colors;
            bright = builtins.mapAttrs (name: value: value.bright) pallette.colors;
          };
      };
    };
  };
}
