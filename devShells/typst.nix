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

  # because it would force the time otherwise
  shellHook = ''
    unset SOURCE_DATE_EPOCH
  '';
}
