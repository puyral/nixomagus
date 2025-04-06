{ config, ... }:
{
  home.file."${config.xdg.configHome}/xkb" = {
    source = ./xkb;
    recursive = true;
  };
}
