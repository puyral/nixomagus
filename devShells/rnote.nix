{
  pkgs,
  self',
  ...
}:
{
  devShells.rnote = pkgs.mkShell {
    name = "rnote";
    inputsFrom = [ self'.packages.rnote ];
    buildInputs = with pkgs; [
      cargo
      cargo-expand
      rust-analyzer
      cargo-nextest
    ];
  };
}
