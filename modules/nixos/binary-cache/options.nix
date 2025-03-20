{ lib, ... }:
{
  options.extra.cache = {
    enable = lib.mkEnableOption "expose nix store";
    port = lib.mkOption {
      type = lib.types.port;
      default = 5000;
    };
    substituter = lib.mkEnableOption "substituter";
  };
}
