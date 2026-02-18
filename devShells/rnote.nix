{
  pkgs,
  inputs',
  ...
}:
{
  devShells.rnote =
pkgs.mkShell {
  name = "rnote";
  inputsFrom = [ inputs'.custom.rnote ];
  buildInputs = with pkgs; [
    cargo
    cargo-expand
    rust-analyzer
    cargo-nextest
  ];
};
}
