{ config, ... }:
{
  config = {
    home.file."${config.xdg.configHome}/xkb" = {
      source = ./xkb;
      recursive = true;
    };

    vars.keyboard.xkb-v3 = ./xkb/symbols/custom;
  };
}
