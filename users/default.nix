{ user, ... }:
{
  lib,
  ...
}:
{
  imports = [
    (import (./. + "/${user.name}"))
    ./all
  ];

  options.extra.user.name = lib.mkOption {
    type = lib.types.str;
    default = user.name;
  };

  # nix.registry = (import ./registeries.nix) attrs;
}
