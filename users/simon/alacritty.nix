{ config, pkgs, ... }:
{
  imports = [ ];

  programs.alacritty = {
    enable = true;
    settings = {

      window = {
        decoration = "None";
        padding = {
          x = 5;
          y = 5;
        };
        dynamic_padding = true;
      };

      font.normal = "Hack";

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

}
