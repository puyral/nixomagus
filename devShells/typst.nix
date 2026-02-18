{
  pkgs,
  ...
}:
{
  devShells.typst = pkgs.mkShell {
    name = "typst";
    buildInputs = with pkgs; [
      typst
      tinymist
    ];

    # because it would force the time otherwise
    shellHook = ''
      unset SOURCE_DATE_EPOCH
    '';
  };
}
