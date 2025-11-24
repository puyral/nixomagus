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
    ]
  );
}
