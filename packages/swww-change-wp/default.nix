{
  writeShellApplication,
  swww,
  gnugrep,
  findutils,
  coreutils,
  gawk,
  gnused,
  ...
}:
writeShellApplication {
  name = "swww-change-wp";
  runtimeInputs = [
    swww
    coreutils
    gnugrep
    findutils
    gawk
    gnused
  ];
  text = builtins.readFile ./script.sh;
}
