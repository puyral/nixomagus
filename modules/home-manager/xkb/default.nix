{ config, pkgs, ... }:
let
  ergol = pkgs.fetchurl {
    url = "https://github.com/Nuclear-Squid/ergol/releases/download/ergol-v1.0.0/ergol.xkb_symbols";
    hash = "sha256-DSxip26R5sacmh9PRmT8WxGj+pUy8swKzmU6c4lh0O4=";
  };

  xkb = pkgs.runCommand "xkb" { } ''
    mkdir -p $out/symbols
    cp -r ${./xkb}/. $out/
    cp ${ergol} $out/symbols/ergo-l
  '';
in
{
  config = {
    home.file."${config.xdg.configHome}/xkb" = {
      source = xkb;
      recursive = true;
    };

    vars.keyboard.xkb-v3 = ./xkb/symbols/custom;
  };
}
