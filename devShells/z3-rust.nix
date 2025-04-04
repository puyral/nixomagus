{ mkShell, cargo, rustPlatform, ... }:
mkShell {
  name = "config";
  buildInputs = [
    cargo
    cargo-expand
    rust-analyser
    rustPlatform.bindgenHook
    z3
  ];
}
