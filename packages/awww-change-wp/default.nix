{
  writeShellApplication,
  awww,
  gnugrep,
  findutils,
  coreutils,
  gawk,
  gnused,
  ...
}:
writeShellApplication {
  name = "awww-change-wp";
  runtimeInputs = [
    awww
    coreutils
    gnugrep
    findutils
    gawk
    gnused
  ];
  text = builtins.readFile ./script.sh;
}
