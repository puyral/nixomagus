{
  pkgs,
  ...
}:
{
  devShells.rust = pkgs.mkShell {
    name = "rust";
    buildInputs = with pkgs; [
      rustPlatform.bindgenHook
      rustPlatform.cargoSetupHook
      cargo
      rustc
      cargo-expand
      rust-analyzer
      clippy
    ];
  };
}
