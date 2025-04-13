{
  writeShellApplication,
  swww,
  ...
}:
writeShellApplication {
  name = "swww-change-wp";
  runtimeInputs = [ swww ];
  text = builtins.readFile ./script.sh;
}
