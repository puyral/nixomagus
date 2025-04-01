{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.extra.controllers;
in
{
  imports = [
    ./nintendo.nix
  ];
  options.extra.controllers = {
    nintendo.enable = lib.mkEnableOption "nintendo controllers";
  };
}
