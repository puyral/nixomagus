user:
{ computer, ... }@attrs:
{
  imports = [
    (./users + "/${user.name}/home.nix")
    (./users + "/${user.name}/${computer.name}.nix")
  ];

  nix.registry = (import ./registery.nix) attrs;

  # better caching
  nix.settings.substituters = [
    "https://aseipp-nix-cache.global.ssl.fastly.net"
    "https://cache.nixos.org/"
    "https://nix-community.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];
}
