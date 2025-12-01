{
  pkgs,
  mkShell,
  typst,
  ...
}:
mkShell {
  name = "typst";
  buildInputs = [
    typst
  ];
}
