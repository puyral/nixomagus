{ nixpkgs, system, ... }:
let
  # https://github.com/NixOS/nixpkgs/issues/341683
  pkgs-stable' = import nixpkgs {
    inherit system;
    config = {
      permittedInsecurePackages = [ "electron-27.3.11" ];
    };
  };

in
{
  home = {
    packages = [ pkgs-stable'.logseq ];
  };
}
