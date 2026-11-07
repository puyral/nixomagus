{
  inputs,
  self,
  config,
  lib,
  ...
}:
{
  flake.lib =
    (import ./enumerate.nix { })
    // (import ./extraArgs.nix {
      inherit
        inputs
        self
        config
        lib
        ;
    });
}
