attrs@{...}:{
  perSystem = {pkgs, ...}: let 
  in {
    imports = [
      ./lean.nix
      ./new-nix.nix
      ./rnote.nix
      ./rust.nix
      ./typst.nix
      ./z3-rust.nix
      ./z3.nix
    ];
    default = pkgs.callPackage ../shell.nix attrs;
  };

}