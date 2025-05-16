{ mkShell, rustPlatform,  cargo, clippy, cargo-expand, rust-analyzer, z3, ... }:
mkShell {
  name = "config";
  RUST_SRC_PATH = "${rustPlatform.rustLibSrc}";
  buildInputs = [
    cargo
    clippy
    cargo-expand
    rust-analyzer
    rustPlatform.bindgenHook
    z3
  ];
}
