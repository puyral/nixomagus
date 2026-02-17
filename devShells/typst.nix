{
  pkgs,
  mkShell,
  typst,
  tinymist,
  ...
}:
mkShell {
  name = "typst";
  buildInputs = [
    typst
    tinymist
  ];

  # because it would force the time otherwise
  shellHook = ''
    unset SOURCE_DATE_EPOCH
  '';
}
