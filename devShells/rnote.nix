{
  mkShell,
  custom,
  cargo-expand,
  rust-analyzer,
  cargo,
  cargo-nextest,
  ...
}:
mkShell {
  name = "rnote";
  inputsFrom = [ custom.rnote ];
  buildInputs =
     [
      cargo
      cargo-expand
      rust-analyzer
      cargo-nextest
    ];
}
