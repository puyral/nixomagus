{
  inputs,
  self,
  config,
  lib,
  ...
}:
{
  extraArgs =
    computer:
    let
      inherit (computer) system;
      inherit (self) rootDir;
      pkgs-self = self.packages.${system};

      overlays = (import (rootDir + /overlays)) {
        inherit computer pkgs-self lib;
      };

      mkPkgs =
        name: nixpkgs:
        import nixpkgs {
          inherit system;
          overlays = overlays.${name} or [ ];
          config = {
            allowUnfree = true;
          };
        };

      # setups things like `pkgs-stable`, `pkgs-unstable` and `pkgs-kernel`...
      nixpkgs-variants = lib.mapAttrs mkPkgs self.nixpkgs-variants;
    in
    inputs
    // nixpkgs-variants
    // {
      inherit
        system
        rootDir
        computer
        pkgs-self
        overlays
        ;
      inherit (config) computers;
      computer_name = computer.name;
      mconfig = computer;
      is_nixos = computer.nixos.enable;
      mlib = self.lib // (import ./pkgs.nix) { pkgs = nixpkgs-variants.pkgs-base; };
    };
}
