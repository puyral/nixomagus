{
  writeShellApplication,
  git,
  coreutils,
  inetutils,
  replaceVars,
  flakePath ? "/config",
  type ? "nixos",
  name ? "simon",
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
      inherit flakePath type name;
    }
  );
}
