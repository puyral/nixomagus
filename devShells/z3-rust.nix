{ mkShell, pkgs, ... }:
mkShell {
  name = "config";
  buildInputs = with pkgs; [
    cargo
    cargo-expand
    rust-analyzer
    rustPlatform.bindgenHook
    z3
  ];
}
