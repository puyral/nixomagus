user:
{ mconfig, lib, ... }@attrs:
let
  computer = mconfig;
in
{
  imports = [
    (import (./users + "/${user.name}/commun"))
    (import (./users + "/${user.name}/${computer.name}"))
    ./modules/home-manager
    ./users/all
  ];

  options.extra.user.name = lib.mkOption {
    type = lib.types.str;
    default = user.name;
  };

  # nix.registry = (import ./registeries.nix) attrs;

  # better caching
  # nix.settings.substituters = [
  #   "https://aseipp-nix-cache.global.ssl.fastly.net"
  #   "https://cache.nixos.org/"
  #   "https://nix-community.cachix.org"
  # ];
  # nix.settings.trusted-public-keys = [
  #   "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  # ];
}
