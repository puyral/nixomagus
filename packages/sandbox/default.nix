{
  writeShellApplication,
  microvmRunner,
  openssh,
  netcat-openbsd,
}:
writeShellApplication {
  name = "sandbox";
  runtimeInputs = [
    openssh
    netcat-openbsd
    microvmRunner
  ];
  text = builtins.readFile ./sandbox.sh;
}
