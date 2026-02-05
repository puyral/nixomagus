{
  pkgs,
  mkShell,
  z3,
  ...
}:
mkShell {
  name = "z3";
  inputsFrom = [ z3 ];
  buildInputs = (
    with pkgs;
    [
      nixd
      cmake
      ninja
      ccache
      python3 # Z3 builds often need python for scripts
    ]
  );

  # Optional: Force CMake to see the correct compiler wrapper
  shellHook = ''
    export CMAKE_GENERATOR="Ninja"
  '';
}
