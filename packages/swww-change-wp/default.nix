{
  writeShellApplication,
  swww,
  gnugrep,
  findutils,
  coreutils,
  ...
}:
writeShellApplication {
  name = "swww-change-wp";
  runtimeInputs = [
    swww
    coreutils
    gnugrep
    findutils
  ];
  text = builtins.readFile ./script.sh;
}
