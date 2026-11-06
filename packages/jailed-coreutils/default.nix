{
  writeShellApplication,
  coreutils,
  findutils,
  replaceVars,
  lib,
  timeout ? "20s",
  gnugrep,
  ...
}:
let
  hints = replaceVars ./hints.txt { inherit timeout; };

  mkJailed =
    name: pkg:
    writeShellApplication {
      inherit name;
      runtimeInputs = [ coreutils ];
      bashOptions = [
        "nounset"
        "pipefail"
      ];
      text = builtins.readFile (
        replaceVars ./${name}.sh {
          inherit timeout hints;
          ${name} = lib.getExe' pkg name;
        }
      );
    };
in
{
  jailedFind = mkJailed "find" findutils;
  jailedGrep = mkJailed "grep" gnugrep;
}
