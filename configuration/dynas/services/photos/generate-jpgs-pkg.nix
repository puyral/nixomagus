{
  writeShellApplication,
  # writeScript,
  writeText,
  darktable,
  python312,
  gen-config,
  ...
}:
let
  configFile = writeText "config.json" (builtins.toJSON gen-config);
in
# configFile = writeText "";
writeShellApplication {
  name = "generate-jpgs";
  runtimeInputs = [ darktable ];
  text = ''
    ${python312}/bin/python ${./generate-jpgs.py} ${configFile}
  '';
}
