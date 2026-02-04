{
  writeShellApplication,
  git,
  coreutils,
  inetutils,
  replaceVars,
  flakePath ? "/config",
  rebuildCmd ? "sudo nixos-rebuild switch --flake '${flakePath}'",
  ...
}:
writeShellApplication {
  name = "rebuild";
  runtimeInputs = [
    git
    coreutils
    inetutils
  ];
  text = builtins.readFile (
    replaceVars ./script.sh {
      inherit rebuildCmd flakePath;
    }
  );
}
