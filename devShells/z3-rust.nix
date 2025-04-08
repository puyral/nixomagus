{ mkShell, pkgs, ... }:
mkShell {
  name = "config";
  buildInputs = with pkgs; [
    cargo
    clippy
    cargo-expand
    rust-analyzer
    rustPlatform.bindgenHook
    z3
  ];
}
