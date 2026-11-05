{
  writeShellApplication,
  findutils,
  replaceVars,
  lib,
  timeout ? "5m",
  ...
}:
writeShellApplication {
  name = "find";
  bashOptions = [
    "nounset"
    "pipefail"
  ];
  text = builtins.readFile (
    replaceVars ./script.sh {
      inherit timeout;
      find = lib.getExe' findutils "find";
    }
  );
}
