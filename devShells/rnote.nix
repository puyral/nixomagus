{
  rustPlatform,
  mkShell,
  custom,
  cargo-expand,
  rust-analyzer,
  ...
}:
mkShell {
  name = "rnote";
  buildInputs = custom.rnote.buildInputs ++ [
    cargo-expand
    rust-analyzer
    rustPlatform.bindgenHook
    rustPlatform.cargoSetupHook
  ];
}
