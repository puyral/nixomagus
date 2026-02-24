{
  pkgs,
  ...
}:
{
  devShells.z3-rust =

    pkgs.mkShell {
      name = "z3.rs";
      RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";

      # Tools needed at build time
      nativeBuildInputs = with pkgs; [
        cmake
        python3
        ninja
        rustPlatform.bindgenHook
      ];

      buildInputs = with pkgs; [
        cargo
        clippy
        cargo-expand
        rust-analyzer
        z3
      ];

      # Force the cmake crate to use Ninja for a much faster Z3 build
      shellHook = ''
        export CMAKE_GENERATOR="Ninja"
      '';
    };
}
