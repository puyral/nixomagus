{
  writeShellApplication,
  replaceVars,
  csandboxSystem,
  systemd,
}:
writeShellApplication {
  name = "csandbox";
  runtimeInputs = [ systemd ];
  text = builtins.readFile (
    replaceVars ./script.sh {
      inherit csandboxSystem;
    }
  );
}
