{
  writeShellApplication,
  # writeScript,
  writeText,
  darktable,
  python312,
  clangStdenv,
  gen-config ? null,
  ...
}:
let
  configFile =
    if gen-config == null then "" else writeText "config.json" (builtins.toJSON gen-config);
    mdarktable = darktable.override{ stdenv = clangStdenv; };
in
# configFile = writeText "";
writeShellApplication {
  name = "generate-jpgs";
  runtimeInputs = [ mdarktable ];
  text = ''
    ${python312}/bin/python ${./generate-jpgs.py} ${configFile}
  '';
}
