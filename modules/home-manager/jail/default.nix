{ lib, ... }:
{
  options.extra.jail = {
    enable = lib.mkEnableOption "jail-specific options";
  };
}
