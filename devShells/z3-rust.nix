{ mkShell, pkgs, ... }:
mkShell {
  name = "config";
  buildInputs = with pkgs; [
    cargo
    cargo-expand
    rust-analyser
    rustPlatform.bindgenHook
    z3
  ];
}
