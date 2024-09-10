{ kmonad, ... }:
{

  imports = [
    ../../configuration.nix
    kmonad.nixosModules.default
  ];
}
