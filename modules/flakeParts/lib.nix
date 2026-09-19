{
  inputs,
  self,
  config,
  lib,
  ...
}:
{
  flake.lib = {
    extraArgs =
      computer:
      let
        inherit (computer) system;
        inherit (self) rootDir;

        mkPkgs =
          nixpkgs:
          import nixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
            };
          };

        # setups things like `pkgs-stable`, `pkgs-unstable` and `pkgs-kernel`...
        nixpkgs-variants = lib.mapAttrs (n: v: mkPkgs v) self.nixpkgs-variants;
      in
      inputs
      // nixpkgs-variants
      // {
        inherit system rootDir computer;
        inherit (config) computers;
        pkgs-self = self.packages.${system};
        computer_name = computer.name;
        mconfig = computer;
        overlays = (import (rootDir + /overlays)) computer;
        is_nixos = computer.nixos.enable;
        mlib = self.lib;
      };

    enumerate =
      with builtins;
      l:
      let
        f =
          acc: e:
          [
            {
              idx = length acc;
              value = e;
            }
          ]
          ++ acc;
      in
      builtins.foldl' f [ ] l;
  };

}
