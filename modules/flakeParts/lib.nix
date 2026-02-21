{
  inputs,
  self,
  config,
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
      in
      inputs
      // (with inputs; {
        pkgs-stable = mkPkgs nixpkgs-stable;
        pkgs-unstable = mkPkgs nixpkgs-unstable;
        pkgs-kernel = mkPkgs nixpkgs-kernel;
        pkgs-self = self.packages.${system};
        custom = custom.packages.${system};
      })
      // {
        inherit system rootDir computer;
        inherit (config) computers;
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
