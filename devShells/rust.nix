{
  rustPlatform,
  mkShell,
  pkgs,
  ...
}:
mkShell {
  name = "rnote";
  buildInputs = with pkgs; [
    rustPlatform.bindgenHook
    rustPlatform.cargoSetupHook
    cargo
    rustc
    cargo-expand
    rust-analyzer
    clippy
  ];
}
