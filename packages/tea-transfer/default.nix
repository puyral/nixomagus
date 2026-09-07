{
  writeShellApplication,
  tea,
  git,
  ...
}:
writeShellApplication {
  name = "tea-transfer";
  runtimeInputs = [
    tea
    git
  ];
  text = builtins.readFile ./tea-transfer.sh;
}
