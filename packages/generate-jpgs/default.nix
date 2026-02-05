{
  writeShellApplication,
  writeText,
  darktable,
  python312,
  gen-config ? null,
  ...
}:
let
  configFile =
    if gen-config == null then "" else writeText "config.json" (builtins.toJSON gen-config);
in
# configFile = writeText "";
writeShellApplication {
  name = "generate-jpgs";
  runtimeInputs = [
    darktable
    python312
  ];
  text = ''
    ${python312}/bin/python ${./generate-jpgs.py} ${configFile}
  '';
}
