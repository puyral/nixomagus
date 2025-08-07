{ computer, pkgs-pinned-darktable, ... }:

{
  imports = [
    ./configuration.nix
    # ./filesystem.nix
    ./services
    ./network.nix
  ];

  nixpkgs.overlays = [
    (final: prev: {
      # Here, we are overriding the 'darktable' package.
      # Instead of using the (broken) one from the main `nixpkgs` input (`prev.darktable`),
      # we are explicitly telling it to use the one from our pinned package set.
      darktable = pkgs-pinned-darktable.darktable;
    })
  ];

}
