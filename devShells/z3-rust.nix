{
  pkgs,
  ...
}:
{
  devShells.z3-rust =

    pkgs.mkShell {
      name = "config";
      RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
      buildInputs = with pkgs; [
        cargo
        clippy
        cargo-expand
        rust-analyzer
        rustPlatform.bindgenHook
        z3
      ];
    };
}
