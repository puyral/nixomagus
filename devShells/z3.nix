{
  pkgs,
  ...
}:
{
  devShells.z3 = pkgs.mkShell {
    name = "z3";
    inputsFrom = [ pkgs.z3 ];
    buildInputs = (
      with pkgs;
      [
        nixd
        cmake
        ninja
        ccache
        python3 # Z3 builds often need python for scripts
        clang-tools
      ]
    );

    # Optional: Force CMake to see the correct compiler wrapper
    shellHook = ''
      export CMAKE_GENERATOR="Ninja"
    '';
  };
}
