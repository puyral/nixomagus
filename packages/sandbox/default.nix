{
  writeShellApplication,
  replaceVars,
  openssh,
  netcat-openbsd,
}:
writeShellApplication {
  name = "sandbox";
  runtimeInputs = [
    openssh
    netcat-openbsd
  ];
  text = builtins.readFile (
    replaceVars ./script.sh {
    }
  );
   meta.broken = true;
}
