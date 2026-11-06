{
  writeShellApplication,
  fd,
  coreutils,
  replaceVars,
  olderThan,
  ...
}:
writeShellApplication {
  name = "direnv-gc";
  runtimeInputs = [
    fd
    coreutils
  ];
  text = builtins.readFile (
    replaceVars ./direnv-gc.sh {
      inherit olderThan;
    }
  );
}
